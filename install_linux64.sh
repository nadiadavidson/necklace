#!/bin/bash

## This script will install the tools required for the pipeline
## It will fetched each tool from the web and place it into the tools/ subdirectory.
## Paths to all installed tools can be found in the file tools.groovy at the
## end of execution of this script. These paths can be changed if a different
## version of software is required. Note that R must be installed manually
##
## Last Modified: 10th Dec 2018 by Nadia Davidson

mkdir -p tools/bin 
cd tools 

#a list of which programs need to be installed
commands="bpipe hisat2 stringtie gffread blat python lace gtf2flatgtf samtools Trinity bowtie2 make_blocks featureCounts chimera_breaker remove_clusters_match final_cluster"
#dedupe reformat"

#installation method
function bpipe_install {
   wget -O bpipe-0.9.9.2.tar.gz https://github.com/ssadedin/bpipe/releases/download/0.9.9.2/bpipe-0.9.9.2.tar.gz
   tar -zxvf bpipe-0.9.9.2.tar.gz ; rm bpipe-0.9.9.2.tar.gz
   ln -s $PWD/bpipe-0.9.9.2/bin/* $PWD/bin/
}

function Trinity_install {
    wget https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v2.4.0.tar.gz
    tar -zxvf Trinity-v2.4.0.tar.gz ; rm Trinity-v2.4.0.tar.gz
    make -C trinityrnaseq-Trinity-v2.4.0
    make plugins -C trinityrnaseq-Trinity-v2.4.0 
    echo "export PATH=$PATH:$PWD/bin ; $PWD/trinityrnaseq-Trinity-v2.4.0/Trinity \$@" > $PWD/bin/Trinity
    chmod +x $PWD/bin/Trinity
}

function hisat2_install {
    wget wget http://ccb.jhu.edu/software/hisat2/dl/hisat2-2.1.0-Linux_x86_64.zip
    unzip hisat2-2.1.0-Linux_x86_64.zip ; rm hisat2-2.1.0-Linux_x86_64.zip
    ln -s $PWD/hisat2-2.1.0/* $PWD/bin/
}

function stringtie_install {
    wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.0.3.tar.gz
    tar xvfz stringtie-2.0.3.tar.gz
    rm stringtie-2.0.3.tar.gz
    make -C stringtie-2.0.3
    ln -s $PWD/stringtie-2.0.3/stringtie $PWD/bin/
}

function gffread_install {
   wget http://ccb.jhu.edu/software/stringtie/dl/gffread-0.9.12.Linux_x86_64.tar.gz
   tar xvfz gffread-0.9.12.Linux_x86_64.tar.gz 
   rm gffread-0.9.12.Linux_x86_64.tar.gz
   ln -s $PWD/gffread-0.9.12.Linux_x86_64/gffread $PWD/bin/ 
}

function blat_install {
   wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v369/blat/blat
   mv blat $PWD/bin
   chmod +x $PWD/bin/blat
}

function fasta_formatter_install {
    wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
    tar -jxvf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
    rm fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
}

function remove_clusters_match_install {
    g++ -o bin/remove_clusters_match ../c_scripts/remove_clusters_match.c++
}

function gtf2flatgtf_install {
    g++ -o bin/gtf2flatgtf ../c_scripts/gtf2flatgtf.c
}

function make_blocks_install {
    g++ -o bin/make_blocks ../c_scripts/make_blocks.c
}

function chimera_breaker_install {
    g++ -o bin/chimera_breaker ../c_scripts/chimera_breaker.c++
}

function final_cluster_install {
    g++ -o bin/final_cluster ../c_scripts/final_cluster.c++
}

function python_install {
   wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
   bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $PWD/miniconda
   rm ./Miniconda3-latest-Linux-x86_64.sh
   ln -s $PWD/miniconda/bin/* $PWD/bin/
   bin/conda config --add channels bioconda
   bin/conda install -y pandas networkx numpy matplotlib
}

function lace_install {
    wget https://github.com/Oshlack/Lace/releases/download/v1.13/Lace-1.13.tar.gz -O Lace-1.13.tar.gz
    tar -xvf Lace-1.13.tar.gz ; rm Lace-1.13.tar.gz
    cd Lace-1.13
    ../bin/conda env create -f environment.yml
    cd ../
    echo "conda $PWD/bin/activate lace ; $PWD/bin/python $PWD/Lace-1.13/Lace.py \$@" > bin/lace
    chmod +x bin/lace
    bin/conda install pandas
}

function samtools_install {
    wget https://github.com/samtools/samtools/releases/download/1.5/samtools-1.5.tar.bz2
    tar -jxvf samtools-1.5.tar.bz2 ; rm samtools-1.5.tar.bz2
    make prefix=$PWD install -C samtools-1.5/
}

function bowtie2_install {
    wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.2/bowtie2-2.3.2-legacy-linux-x86_64.zip
    unzip bowtie2-2.3.2-legacy-linux-x86_64.zip
    rm bowtie2-2.3.2-legacy-linux-x86_64.zip
    ln -s $PWD/bowtie2-2.3.2-legacy/bowtie2* $PWD/bin/
}

function featureCounts_install {
    wget https://sourceforge.net/projects/subread/files/subread-1.5.3/subread-1.5.3-Linux-x86_64.tar.gz
    tar -xvf subread-1.5.3-Linux-x86_64.tar.gz ; rm subread-1.5.3-Linux-x86_64.tar.gz
    ln -s $PWD/subread-1.5.3-Linux-x86_64/bin/* $PWD/bin
}

echo "// Path to tools used by the pipeline" > ../tools.groovy

for c in $commands ; do 
    c_path=`which $PWD/bin/$c 2>/dev/null`
    if [ -z $c_path ] ; then 
	echo "$c not found, fetching it"
	${c}_install
	c_path=`which $PWD/bin/$c 2>/dev/null`
    fi
    echo "$c=\"$c_path\"" >> ../tools.groovy
done

#loop through commands to check they are all installed
echo "Checking that all required tools were installed:"
Final_message="All commands installed successfully!"
for c in $commands ; do
    c_path=`which $PWD/bin/$c 2>/dev/null`
    if [ -z $c_path ] ; then
	echo -n "WARNING: $c could not be found!!!! " 
	echo "You will need to download and install $c manually, then add its path to tools.groovy"
	Final_message="WARNING: One or more command did not install successfully. See warning messages above. \
                       You will need to correct this before running the pipeline."
    else 
        echo "$c looks like it has been installed"
    fi
done
echo "**********************************************************"
echo $Final_message



