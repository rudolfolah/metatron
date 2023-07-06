# metatron

Metatron is a project that brings together `whisper.cpp`, `llama.cpp`, and `piper` into a deployable stack with an awesome Node.js API wrapper for each of them.

Why? So you can deploy and scale out each part in your own network, and use the API to interact with them:
* Send audio through the whisper API for a transcription
* Send a prompt through llama API for a response
* Send a response through piper API for text-to-speech audio

## Usage

```
git submodule update --init --recursive
cd piper && docker buildx build --target build -t piper:latest .

# for local development
docker build --target localdev -t metatron-api:localdev -f ./Dockerfile-api .
docker build --target localdev -t metatron-piper:localdev -f ./Dockerfile-piper .
docker build --target localdev -t metatron-llama:localdev -f ./Dockerfile-llama .
docker build --target localdev -t metatron-whisper:localdev -f ./Dockerfile-whisper .
docker compose up

# for production
docker build -t metatron-api:latest -f ./Dockerfile-api .
docker build -t metatron-piper:latest -f ./Dockerfile-piper .
docker build -t metatron-llama:latest -f ./Dockerfile-llama .
docker build -t metatron-whisper:latest -f ./Dockerfile-whisper .
```

Debugging:
```
docker build -t metatron --no-cache .
```

## Architecture

```mermaid
sequenceDiagram
    participant Web as web app
    participant A as API
    participant K as Kafka
    participant W_whisper as whisper.cpp worker
    participant W_llama as llama.cpp worker
    participant W_piper as piper worker
    Web ->> A: request (http)
    A ->> K: queue transcribe
    K ->> W_whisper: process
    W_whisper ->> K: queue prompt
    K ->> W_llama: process
    W_llama ->> K: queue llama
    K ->> W_piper: process
    W_piper ->> K: queue completed
    loop
        K ->> A: completed
        A -->> Web: response (websocket)
    end
```

```mermaid
graph TD
    A[API] <--> K[Kafka]
    S[Storage] --> A
    K <--> W_piper[piper\nworker]
    K <--> W_whisper[whisper.cpp\nworker]
    K <--> W_llama[llama.cpp\nworker]
    Web[web app] --request--> A
    Web <--web socket--> A
    K --> Z[Zookeeper]
    W_piper --> S
    W_whisper --> S
    W_llama --> S
```