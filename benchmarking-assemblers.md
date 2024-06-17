## Comparison of available primary assemblers from long reads

Benchmarking - Setonix HPC performance, using the flollowing settings on Slurm:

* ```--exclusive``` - used exclusive node for benchmarking    
* ```--cpus-per-task=24```    
* ```--nodes=1```    
* ```--ntasks=1```     
* ```--partition=work```    
* ```--mem=200G``` - maximum memory for work queue    


| Assembler        | Wall-clock time | CPU time   | Memory Utilized |
|------------------|-----------------|------------|-----------------|
| CANU             | 04:52:07        | 4-15:32:44 | 62.21 GB        |
| Flye             | 03:36:25        | 2-15:27:51 | 48.03 GB        |
| NextDenovo       | 00:23:12        | 22:00:24   | 159.06 GB       |
| Wtdbg2 (redbean) | 00:33:29        | 12:27:42   | 6.19 GB         |
| Raven            | 04:37:46        | 4-02:00:55 | 73.81 GB        |
| Unicycler - lr   | NA              | NA         | > 890 GB        |

Assembly contiguity and stats for test sample:    

| Assembler        | # of contigs | N50    | min   | max    | Genome size |
|------------------|--------------|--------|-------|--------|-------------| 
| CANU             | 53           | 2619752| 1573  | 4510360| 42.37e6     |
| Flye             | 422          | 211792 | 574   | 1031083| 38.88e6     |
| NextDenovo       | 9            | 125536 | 82914 | 170627 | 1076432     |
| Wtdbg2 (redbean) | 209          | 595416 | 3277  | 1338536| 36.82e6     |
| Raven            | 177          | 689747 | 11657 | 4191860| 45.38e6     |
| Unicycler - lr   | NA           | NA     | NA    | NA     | NA          |

* GoldRush does not work with reads missing Phred quality scores, thus cannot be used for RSII reads PB.    
* Unicycler runs our of memory, thus not considered here for assembly.    

## Comparison for hybrid assemblers

| Assembler        | Wall-clock time | CPU time   | Memory Utilized |
|------------------|-----------------|------------|-----------------|
| Spades           | 03:45:11        | 2-22:34:13 | 18.24 GB        |
| Unicycler - lr + sr  | NA (time-out)        | NA | NA         |

Assembly contiguity and stats for test sample:   

| Assembler        | # of contigs | N50    | min   | max    | Genome size |
|------------------|--------------|--------|-------|--------|-------------|
| Spades           | 28688        | 342047 | 500   | 1121776| 38.57e6     |
| Unicycler - lr + sr |    NA        | NA | NA  | NA |  NA    |
