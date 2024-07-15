//nvcc -Xcompiler -fopenmp  main.cu -o main && ./main Examples/t.txt Examples/test_ME.txt Examples/test_CC1.txt Examples/test_map.txt Examples/test_change1.txt 2 1

#include <iostream>
#include <fstream>
#include <vector>
#include <stdio.h>
#include <string.h>
#include <map>
#include <cmath>
#include <omp.h>
#include <unordered_map>
#include "DataStructure.hpp"
#include "ReadData.hpp"
#include "CreateGraph.hpp"
//#include "TraverseMeta.hpp"
#include "PrintFunctions.hpp"

using namespace std;

typedef pair<int,int> int_int;

// #define DEBUG 

// CUDA kernel to mark hubs
__global__ void markHubs(int_int* inserts_meta, MetaNode* MN_list, int size) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) {
        int src = inserts_meta[i].first;
        int dest = inserts_meta[i].second;
        MN_list[src].is_hub = true;
        MN_list[dest].is_hub = true;
    }
}

// CUDA kernel to process nodes
__global__ void processNodes(int* g_meta_out_deg, int* g_meta_in_deg, int* gI_meta_out_deg, int* gI_meta_in_deg,
                             MetaNode* MN_list, int* Hub_Id, int N, int* non_zero, int trim_th, int hub_th_high, int hub_th_low) {
    int mn = blockIdx.x * blockDim.x + threadIdx.x;
    if (mn < N) {
        if (g_meta_out_deg[mn] <= trim_th && gI_meta_out_deg[mn] <= trim_th) {
            MN_list[mn].trimmed = true;
            MN_list[mn].is_hub = false;
            return;
        }
        if (g_meta_in_deg[mn] <= trim_th && gI_meta_in_deg[mn] <= trim_th) {
            MN_list[mn].trimmed = true;
            MN_list[mn].is_hub = false;
            return;
        }

        if (gI_meta_out_deg[mn] > 0)
            MN_list[mn].down = 1;
        if (gI_meta_in_deg[mn] > 0)
            MN_list[mn].up = 1;

        if ((g_meta_out_deg[mn] > hub_th_high || g_meta_in_deg[mn] > hub_th_high) &&
            (g_meta_out_deg[mn] > hub_th_low && g_meta_in_deg[mn] > hub_th_low)) {
            MN_list[mn].Hub_info[*non_zero] = 5;
            MN_list[mn].h_idx = *non_zero;
            Hub_Id[*non_zero] = mn;

            MN_list[mn].up = 1;
            MN_list[mn].down = 1;

            

            atomicAdd(non_zero, 1);
            return;
        }

        if (MN_list[mn].is_hub == true) {
            MN_list[mn].Hub_info[*non_zero] = 5;
            MN_list[mn].h_idx = *non_zero;
            MN_list[mn].up = 1;
            MN_list[mn].down = 1;

            

            atomicAdd(non_zero, 1);
        }
    }
}
int main(int argc, char *argv[]) {
    

    check_file_open(argv[1], argv[2], argv[3], argv[4], argv[5], argc);
    int n, N, m, M; // number of nodes and metanodes
    int p = atoi(argv[7]); // number of threads

    double start_timer, st;

    int *e_src, *e_dest, *e_wt, *m_src, *m_dest, *m_wt;
    bool* insert_status;
    bool* delete_status;

    Graph g, g_meta, gI_meta;

    vector<int> SCCx; // SCC IDs for graph nodes
    unordered_map<int, int> sccMAP; // Mapping of SCCID from old to new 0 to N Continuous
    vector<int_int> edge_list, inserts, deletes, inserts_meta, deletes_meta;
    inserts.clear();
    deletes.clear();
    inserts_meta.clear();
    deletes_meta.clear();
    

    printf("Threads: %d \n", p);

    // ******************* READING FILES ****************************
    start_timer = omp_get_wtime();
    read_graph(argv[1], n, m, e_src, e_dest, e_wt); // reading the graph data
    read_graph(argv[2], N, M, m_src, m_dest, m_wt); // reading the metagraph data
    read_scc(argv[3], n, &SCCx);
    read_sccmap(argv[4], &sccMAP);
    read_changes(argv[5], &inserts, &deletes, &inserts_meta, &deletes_meta, &SCCx, &sccMAP);
    color("purple");
    printf("\n Time for Reading: %f \n", (float)(omp_get_wtime() - start_timer));
    color("reset");

    
    // ******************* READING COMPLETED ****************************

    // Processing Inserts
    st = omp_get_wtime();
    sort(inserts_meta.begin(), inserts_meta.end(), sort_first_second);
    inserts_meta.erase(unique(inserts_meta.begin(), inserts_meta.end()), inserts_meta.end());
    int insert_percent = floor((double)inserts_meta.size() / (double)M * 100.0);

    int *ins_src = new int[inserts_meta.size()];
    int *ins_dest = new int[inserts_meta.size()];
    for (int i = 0; i < inserts_meta.size(); i++) {
        ins_src[i] = inserts_meta[i].first;
        ins_dest[i] = inserts_meta[i].second;
    }

    printf("%d  %d %d", M, inserts_meta.size(), insert_percent);
    color("purple");
    printf("\n Time for Processing Inserts: %f \n", (float)(omp_get_wtime() - st));
    color("reset");

    // ******************* CREATING GRAPHS ****************************
    st = omp_get_wtime();
    create_graph(e_src, e_dest, e_wt, n, m, &g); // GRAPH
    create_graph(m_src, m_dest, m_wt, N, M, &g_meta); // METAGRAPH
    create_graph(ins_src, ins_dest, e_wt, N, inserts_meta.size(), &gI_meta); // INSERTION GRAPH
    color("purple");
    printf("\n Time for Creating graph: %f \n", (float)(omp_get_wtime() - st));
    color("reset");
    // ******************* CREATING GRAPHS COMPLETED ****************************

    st = omp_get_wtime();
    MetaNode* MN_list = new MetaNode[N]; // Allocate MN_list on host
    MetaNode* d_MN_list;
    int_int* d_inserts_meta;
    int* d_Hub_Id;
    int* d_non_zero;
    int* d_g_meta_out_deg;
    int* d_g_meta_in_deg;
    int* d_gI_meta_out_deg;
    int* d_gI_meta_in_deg;

    int hubX = 0;
    int non_zero = 0;
    int trim_th = 0; // nodes with degree <= threshold are trimmed
    int hub_th_high = 30; // nodes with degree >= threshold are hubs
    int hub_th_low = 3; // nodes with degree >= threshold are hubs

    // Allocate device memory
    cudaMalloc(&d_inserts_meta, inserts_meta.size() * sizeof(int_int));
    cudaMalloc(&d_MN_list, N * sizeof(MetaNode));
    cudaMalloc(&d_Hub_Id, 1000 * sizeof(int));
    cudaMalloc(&d_non_zero, sizeof(int));
    cudaMalloc(&d_g_meta_out_deg, N * sizeof(int));
    cudaMalloc(&d_g_meta_in_deg, N * sizeof(int));
    cudaMalloc(&d_gI_meta_out_deg, N * sizeof(int));
    cudaMalloc(&d_gI_meta_in_deg, N * sizeof(int));

    // Copy data to device
    cudaMemcpy(d_inserts_meta, inserts_meta.data(), inserts_meta.size() * sizeof(int_int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_MN_list, MN_list, N * sizeof(MetaNode), cudaMemcpyHostToDevice);
    cudaMemcpy(d_non_zero, &non_zero, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_g_meta_out_deg, g_meta.out_deg, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_g_meta_in_deg, g_meta.in_deg, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_gI_meta_out_deg, gI_meta.out_deg, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_gI_meta_in_deg, gI_meta.in_deg, N * sizeof(int), cudaMemcpyHostToDevice);

    // Define block and grid sizes
    int blockSize = 256;
    int numBlocks = (inserts_meta.size() + blockSize - 1) / blockSize;

    // Launch kernel to mark hubs
    markHubs<<<numBlocks, blockSize>>>(d_inserts_meta, d_MN_list, inserts_meta.size());
    cudaDeviceSynchronize();

    cudaMemcpy(MN_list, d_MN_list, N * sizeof(MetaNode), cudaMemcpyDeviceToHost);
    // Count the number of hubs
    for (int mn = 0; mn < N; mn++) {
        if (MN_list[mn].is_hub == true)
            hubX++;
    }
    printf("HUBs %d", hubX);

    numBlocks = (N + blockSize - 1) / blockSize;

    // Launch kernel to process nodes
    processNodes<<<numBlocks, blockSize>>>(d_g_meta_out_deg, d_g_meta_in_deg, d_gI_meta_out_deg, d_gI_meta_in_deg,
                                           d_MN_list, d_Hub_Id, N, d_non_zero, trim_th, hub_th_high, hub_th_low);
    cudaDeviceSynchronize();

    // Copy results back to host
    cudaMemcpy(MN_list, d_MN_list, N * sizeof(MetaNode), cudaMemcpyDeviceToHost);
    cudaMemcpy(&non_zero, d_non_zero, sizeof(int), cudaMemcpyDeviceToHost);

    // Free device memory
    cudaFree(d_inserts_meta);
    cudaFree(d_MN_list);
    cudaFree(d_Hub_Id);
    cudaFree(d_non_zero);
    cudaFree(d_g_meta_out_deg);
    cudaFree(d_g_meta_in_deg);
    cudaFree(d_gI_meta_out_deg);
    cudaFree(d_gI_meta_in_deg);


    

    color("purple");
    printf("\n Time for Finding Hubs: %f \n", (float)(omp_get_wtime() - st));
    color("reset");
    non_zero++;
    printf("\n N: %d Hubs: %d \n", N, non_zero);

    delete[] MN_list; // Free host memory
    delete[] ins_src;
    delete[] ins_dest;

    return 0;
}
