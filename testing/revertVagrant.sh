#!/bin/sh

vagrant snapshot restore ubuntu clean
vagrant snapshot restore fedora clean
vagrant snapshot restore alpine clean
vagrant snapshot restore rocky clean

