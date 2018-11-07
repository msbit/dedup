# dedup

Simple script to determine duplicate and unique files based on their contents.

Passes over all provided base paths, generating three maps of digest to filenames, in JSON format:

* all file digests (`dedup.all.json`)
* duplicate file digests (`dedup.duplicate.json`)
* unique file digests (`dedup.unique.json`)

If called without any arguments, only look in the current directory.
