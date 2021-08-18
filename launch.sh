#!/bin/sh

echo "Running user: $(id)"


uvicorn main:app --port 5011 --host 0.0.0.0
