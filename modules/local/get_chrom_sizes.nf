process GET_CHROM_SIZES {
    tag "$fasta"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'genome', meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? "bioconda::samtools=1.10" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.10--h9402c20_2':
        'quay.io/biocontainers/samtools:1.10--h9402c20_2' }"

    input:
    path fasta

    output:
    path '*.sizes'     , emit: sizes
    path '*.fai'       , emit: fai
    path "versions.yml", emit: versions

    script:
    """
    samtools \\
        faidx \\
        $fasta

    cut -f 1,2 ${fasta}.fai > ${fasta}.sizes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
