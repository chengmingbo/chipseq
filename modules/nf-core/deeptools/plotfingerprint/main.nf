process DEEPTOOLS_PLOTFINGERPRINT {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/deeptools:3.5.5--pyhdfd78af_0':
        'biocontainers/deeptools:3.5.5--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(bams), path(bais)

    output:
    tuple val(meta), path("*.pdf")          , emit: pdf
    tuple val(meta), path("*.raw.txt")      , emit: matrix
    tuple val(meta), path("*.qcmetrics.txt"), emit: metrics
    path  "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    meta.single_end = true
    def extend   = (meta.single_end && params.fragment_size > 0) ? "--extendReads ${params.fragment_size}" : ''
    """
    plotFingerprint \\
        $args \\
        $extend \\
        --bamfiles ${bams.join(' ')} \\
        --plotFile ${prefix}.plotFingerprint.pdf \\
        --outRawCounts ${prefix}.plotFingerprint.raw.txt \\
        --outQualityMetrics ${prefix}.plotFingerprint.qcmetrics.txt \\
        --numberOfProcessors $task.cpus

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(plotFingerprint --version | sed -e "s/plotFingerprint //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.plotFingerprint.pdf
    touch ${prefix}.plotFingerprint.raw.txt
    touch ${prefix}.plotFingerprint.qcmetrics.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(plotFingerprint --version | sed -e "s/plotFingerprint //g")
    END_VERSIONS
    """
}
