#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HELLO } from "./modules/hello"

workflow {
    HELLO("world")
}
