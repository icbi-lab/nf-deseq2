# nf-deseq2
A RNA-seq differential expression analysis pipeline downstream of nf-core/rnaseq.

## Prerequisites
 * Linux or MacOS, or Windows subsystem for Linux.
 * [Nextflow](https://nextflow.io/)
 * `conda` or `mamba`. If you don't have a conda installation, we recommend getting [mambaforge](https://github.com/conda-forge/miniforge#mambaforge).


## Usage

TODO: Document how the pipeline can be ran and what input parameters it needs.

## Output

TODO: Document the pipeline's output files and how to interpret them.


## Developer docs

### Setting up the editor
 * If you are working with VSCode, we recommend installing the [nf-core-extensionpack](https://marketplace.visualstudio.com/items?itemName=nf-core.nf-core-extensionpack)
   which makes it easier to work with nextflow files. See also the docs on [nf-co.re](https://nf-co.re/developers/editor_plugins#vscode)

### Running tests

 * To run the pipeline on the testdata, run

   ```bash
   nextflow run main.nf -c tests/test.config
   ```

  * To run the exact same tests as on the continuous integration, you need to install
    `pytest-workflow`

    ```bash
    pip install pytest-workflow
    ```

    Then, to run the tests and verify the outputs, run

    ```bash
    pytest ytest --tag deseq2 --kwdof
    ```

