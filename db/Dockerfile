FROM ncbi/blast:2.10.0

WORKDIR /db
VOLUME ["/db"]

ENV DATA_STORE=https://v1.legumefederation.org/data/public
RUN printf '%s\n' '#!/bin/bash' 'set -o pipefail -o errexit -o nounset; curl ${DATA_STORE}/${1} | gzip -dc | sed "s/\(gly[a-z][a-z]\.[[:alnum:]]\{1,\}\.gnm[0-9]\{1,\}\.\(ann[0-9]\{1,\}\.\)\{0,1\}\([^[:space:]]*\)\)/\3 dsid=\1/" | makeblastdb -parse_seqids -hash_index -dbtype ${2} -taxid ${3} -title "${4}" -out $(basename ${1#.f*.gz})' > /usr/local/bin/mkblastdb \
  && chmod +x /usr/local/bin/mkblastdb

RUN curl https://ftp.ncbi.nlm.nih.gov/genomes/refseq/plant/Glycine_max/all_assembly_versions/GCF_000004515.5_Glycine_max_v2.1/GCF_000004515.5_Glycine_max_v2.1_assembly_structure/non-nuclear/assembled_chromosomes/FASTA/chrMT.fna.gz | gzip -dc | makeblastdb -parse_seqids -hash_index -dbtype nucl -taxid 3847 -title 'Glycine max mitochondrial genome' -out chrMT
RUN curl https://ftp.ncbi.nlm.nih.gov/genomes/refseq/plant/Glycine_max/all_assembly_versions/GCF_000004515.5_Glycine_max_v2.1/GCF_000004515.5_Glycine_max_v2.1_assembly_structure/non-nuclear/assembled_chromosomes/FASTA/chrPltd.fna.gz | gzip -dc | makeblastdb -parse_seqids -hash_index -dbtype nucl -taxid 3847 -title 'Glycine max chloroplast genome' -out chrPltd
# causes SequenceServer incompatibility warning due to non-unique sequence IDs
#RUN curl https://soybase.org/GlycineBlastPages/archives/fn_indels.nt.20140304.fasta.gz | gzip -dc | makeblastdb -hash_index -dbtype nucl -taxid 3847 -title 'Fast Neutron InDels Bolon et al. 2014' -out fn_indels.nt.20140304
RUN mkblastdb Glycine_max/Wm82.gnm4.ann1.T8TQ/glyma.Wm82.gnm4.ann1.T8TQ.transcript.fna.gz nucl 3847 'Williams 82 Assembly 4 Annotation 1 (Wm82.a4.v1) Transcript Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm4.ann1.T8TQ/glyma.Wm82.gnm4.ann1.T8TQ.cds.fna.gz nucl 3847 'Williams 82 Assembly 4 Annotation 1 (Wm82.a4.v1) Coding Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm4.4PTR/glyma.Wm82.gnm4.4PTR.genome_main.fna.gz nucl 3847 'Williams 82 Assembly 4 Genomic Sequence (Wm82.a4)'
RUN mkblastdb Glycine_max/Wm82.gnm2.DTC4/glyma.Wm82.gnm2.DTC4.genome_main.fna.gz nucl 3847 'Williams 82 Assembly 2 Genomic Sequence (Wm82.a2)'
RUN mkblastdb Glycine_max/Wm82.gnm2.ann1.RVB6/glyma.Wm82.gnm2.ann1.RVB6.transcript.fna.gz nucl 3847 'Williams 82 Assembly 2 Annotation 1 (Wm82.a2.v1) Transcript Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm2.ann1.RVB6/glyma.Wm82.gnm2.ann1.RVB6.cds.fna.gz nucl 3847 'Williams 82 Assembly 2 Annotation 1 (Wm82.a2.v1) Coding Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm1.FCtY/glyma.Wm82.gnm1.FCtY.genome_main.fna.gz nucl 3847 'Williams 82 Assembly 1 Genomic Sequence (Wm82.a1)'
RUN mkblastdb Glycine_max/Wm82.gnm1.ann1.DvBy/glyma.Wm82.gnm1.ann1.DvBy.cds.fna.gz nucl 3847 'Williams 82 Assembly 1 Annotation 1.1 (Wm82.a1.v1.1)'
RUN mkblastdb Glycine_max/Wm82.gnm1.ann1.DvBy/glyma.Wm82.gnm1.ann1.DvBy.transcripts.fna.gz nucl 3847 'Williams 82 Assembly 1 Annotation 1.1 (Wm82.a1.v1.1) Transcript Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm4.ann1.T8TQ/glyma.Wm82.gnm4.ann1.T8TQ.protein.faa.gz prot 3847 'Williams 82 Assembly 4 Annotation 1 (Wm82.a4.v1) Protein Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm2.ann1.RVB6/glyma.Wm82.gnm2.ann1.RVB6.protein.faa.gz prot 3847 'Williams 82 Assembly 2 Annotation 1 (Wm82.a2.v1) Protein Sequences'
RUN mkblastdb Glycine_max/Wm82.gnm1.ann1.DvBy/glyma.Wm82.gnm1.ann1.DvBy.protein.faa.gz prot 3847 'Williams 82 Assembly 1 Annotation 1.1 (Wm82.a1.v1.1) Protein Sequences'
RUN mkblastdb Glycine_max/Lee.gnm1.ann1.6NZV/glyma.Lee.gnm1.ann1.6NZV.cds.fna.gz nucl 3847 'Glycine max cultivar Lee CDS Sequences'
RUN mkblastdb Glycine_max/Lee.gnm1.ann1.6NZV/glyma.Lee.gnm1.ann1.6NZV.protein.faa.gz prot 3847 'Glycine max cultivar Lee Transcript Protein Sequences'
RUN mkblastdb Glycine_max/Lee.gnm1.BXNC/glyma.Lee.gnm1.BXNC.genome_main.fna.gz nucl 3847 'Glycine max cultivar Lee Genomic Sequence'
RUN mkblastdb Glycine_max/Lee.gnm1.ann1.6NZV/glyma.Lee.gnm1.ann1.6NZV.transcript.fna.gz nucl 3847 'Glycine max cultivar Lee Transcript Sequences'
RUN mkblastdb Glycine_max/Zh13.gnm1.ann1.8VV3/glyma.Zh13.gnm1.ann1.8VV3.cds.fna.gz nucl 3847 'Glycine max cultivar Zhonghuang 13 CDS Sequences'
RUN mkblastdb Glycine_max/Zh13.gnm1.N6C8/glyma.Zh13.gnm1.N6C8.genome_main.fna.gz nucl 3847 'Glycine max cultivar Zhonghuang 13 Genomic Sequence'
RUN mkblastdb Glycine_max/Zh13.gnm1.ann1.8VV3/glyma.Zh13.gnm1.ann1.8VV3.protein.faa.gz prot 3847 'Glycine max cultivar Zhonghuang 13 Protein Sequence'
RUN mkblastdb Glycine_soja/W05.gnm1.ann1.T47J/glyso.W05.gnm1.ann1.T47J.cds.fna.gz nucl 3848 'Glycine soja cultivar W05 CDS sequences'
RUN mkblastdb Glycine_soja/W05.gnm1.ann1.T47J/glyso.W05.gnm1.ann1.T47J.transcript.fna.gz nucl 3848 'Glycine soja cultivar W05 transcript sequences'
RUN mkblastdb Glycine_soja/W05.gnm1.SVL1/glyso.W05.gnm1.SVL1.genome_main.fna.gz nucl 3848 'Glycine soja cultivar W05 genomic sequence'
RUN mkblastdb Glycine_soja/W05.gnm1.ann1.T47J/glyso.W05.gnm1.ann1.T47J.protein.faa.gz prot 3848 'Glycine soja cultivar W05 protein sequences'
RUN mkblastdb Glycine_soja/PI483463.gnm1.ann1.3Q3Q/glyso.PI483463.gnm1.ann1.3Q3Q.transcript.fna.gz nucl 3848 'Glycine soja PI483463 Transcript Sequences'
RUN mkblastdb Glycine_soja/PI483463.gnm1.ann1.3Q3Q/glyso.PI483463.gnm1.ann1.3Q3Q.protein.faa.gz prot 3848 'Glycine soja PI483463 Protein Sequences'
RUN mkblastdb Glycine_soja/PI483463.gnm1.YJWS/glyso.PI483463.gnm1.YJWS.genome_main.fna.gz nucl 3848 'Glycine soja PI483463 Genome Sequence'
RUN mkblastdb Glycine_soja/PI483463.gnm1.ann1.3Q3Q/glyso.PI483463.gnm1.ann1.3Q3Q.cds.fna.gz nucl 3848 'Glycine soja PI483463 Coding Sequence'
RUN mkblastdb Glycine_max/Wm82.gnm4.pan.W46N/glyma.Wm82.gnm4.pan.W46N.PanSoy_seq_not_in_Wm82.fna.gz nucl 3847 'PanSoy dataset: genomic sequence from 204 accessions but not in Wm82.a4'
