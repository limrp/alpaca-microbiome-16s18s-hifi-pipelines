# Alpaca Microbiome 16S/18S HiFi Pipelines

![Workflow](./imgs/ChatGPT_Image_June_23_2026_12_38_10AM_edited.png)

## Workflow

![Workflow](./imgs/ChatGPT_Image_Jun22_2026_12_23_10PM.png)

## Workflow

![Workflow](./imgs/ChatGPTImageJun23_2026_01_45_58PM.png)

## Workflow

![Workflow](./imgs/ChatGPTImageJun24_2026_10_24_47AM.png)

## Workflow

![Workflow](./imgs/ChatGPTImageJun24_2026_11_38_19PM.png)

## Workflow

![Workflow](./imgs/ChatGPTImageJun25_2026_08_17_22PM.png)

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
