#!/bin/bash -l

#Requires a tab delimited list of paired end files with desired name (list, $1)
#SRR1613242_1  SRR1613242_2 SRR1613242

#Requires a path to indexed reference genome (ref, $2)

#bash ../doAlign-unzipped.sh files.txt /home/maccamp/genomes/hypomesus-20210204/Hyp_tra_F_20210204.fa

list=$1
ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
        string="sed -n ${x}p ${list}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2, $3}')   
        set -- $var
        c1=$1
        c2=$2
        c3=$3

       echo "#!/bin/bash -l
       bwa mem $ref ${c1}.fastq ${c2}.fastq | samtools view -Sb | samtools sort - -o ${c3}.sort.bam
       samtools index ${c3}.sort.bam
       samtools view -f 0x2 -b ${c3}.sort.bam | samtools rmdup - ${c3}.sort.flt.bam
       samtools index ${c3}.sort.flt.bam" > ${c3}.sh
       sbatch -p med -t 4-10:00:00 --mem=8G ${c3}.sh

       x=$(( $x + 1 ))

done


