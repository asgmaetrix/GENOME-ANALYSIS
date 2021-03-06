library(DESeq2)
library(tidyverse)
install.packages(pheatmap)

setwd("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq")


> rna_SRR6040092_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040092_counts.txt", header=FALSE)
>   View(rna_SRR6040092_counts)
> rna_SRR6040093_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040093_counts.txt", header=FALSE)
>   View(rna_SRR6040093_counts)
> rna_SRR6040094_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040094_counts.txt", header=FALSE)
>   View(rna_SRR6040094_counts)
> rna_SRR6040095_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040095_counts.txt", header=FALSE)
>   View(rna_SRR6040095_counts)
> rna_SRR6040096_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040096_counts.txt", header=FALSE)
>   View(rna_SRR6040096_counts)
> rna_SRR6040097_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6040097_counts.txt", header=FALSE)
>   View(rna_SRR6040097_counts)
> rna_SRR6156066_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6156066_counts.txt", header=FALSE)
>   View(rna_SRR6156066_counts)
> rna_SRR6156067_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6156067_counts.txt", header=FALSE)
>   View(rna_SRR6156067_counts)
> rna_SRR6156069_counts <- read.delim("C://Users//Girish P.Pulinkala//Desktop//transcriptome//htseq//SRR6156069_counts.txt", header=FALSE)
>   View(rna_SRR6156069_counts)

rna<-merge(rna_SRR6040092_counts,rna_SRR6040093_counts,by="V1")
rna<-merge(rna,rna_SRR6040096_counts,by="V1")
rna<-merge(rna,rna_SRR6040097_counts,by="V1")
names(rna) <- c("V1","leaf","root","stem","aril")
rownames(rna)<-rna[,1]
rna<-rna[,-1]
rna<-rna[-1,]
#run 5 times rna<-rna[-1,]

treat<-c("nonfruit","nonfruit","nonfruit","fruit")
metadata <- data.frame(row.names=colnames(rna), treat)


////dds <- DESeqDataSetFromMatrix(rna, metadata, design= ~ treat)
dds <- DESeqDataSetFromMatrix(countData=rna, colData=metadata, design= ~ treat)


dds <- DESeq(dds)

#PCA
rld<-rlog(dds)
#or:  rld <- rlogTransformation(dds)
colData(dds)
plotPCA(rld,intgroup=c("treat","sizeFactor"))
#check normalization
#plot( assay(rld)[ , 1:2],col=rgb(0,0,0,.2), pch=16, cex=0.3 

#MA
res <- results(dds)
#res <- tbl_df(res)
plotMA(res)

#Ordering
head(res)
summary(res)
resOrdered <- res[order(res$padj),]  #order by padj(adjusted p-value), small padj indicates large difference
resOrdered=as.data.frame(resOrdered)
head(resOrdered)
resOrdered=na.omit(resOrdered)  #delete NA values
write.csv(resOrdered,"resOrdered.csv")

#heatmap#
select<- head(order(res$padj), 15)  #for top 15 padj genes
#also try [1:1182]
#select<-order(rowMeans(counts(dds,normalized=TRUE)),decreasing = TRUE)[1:1182] 
nt<-normTransform(dds)
log2.norm.counts<-assay(nt)[select,]
df<-as.data.frame(colData(dds))
install.packages('pheatmap')
library(pheatmap)
pheatmap(log2.norm.counts,cluster_rows = TRUE,show_rownames = FALSE,cluster_cols = TRUE,annotation_col = df)
#p