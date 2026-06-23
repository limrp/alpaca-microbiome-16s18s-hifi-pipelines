# Alpaca Microbiome 16S/18S HiFi Pipelines

![Workflow](./imgs/ChatGPT_Image_June_23_2026_12_38_10AM_edited.png)

## Workflow

![Workflow](./imgs/ChatGPT_Image_Jun22_2026_12_23_10PM.png)

## Execution methods

QC-only:
```bash
nextflow run main.nf --mode qc_only -profile local -resume
```

Benchmarking:
```bash
nextflow run main.nf --mode benchmarking -profile local -resume
```

Recommended:
```bash
nextflow run main.nf --mode recommended -profile local -resume
```

## Notas
- El modo `qc_only` genera estadísticas pre/post-trim y un reporte HTML.
- `-resume` reutiliza tareas completadas si no cambian entradas/parámetros.
