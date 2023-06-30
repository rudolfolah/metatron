# metatron

Metatron is a project that brings together `whisper.cpp`, `llmama.cpp`, and `piper` into one Docker container with an awesome Node.js API wrapper.

Dockerfile is based on:
* [llmama Dockerfile](https://github.com/ggerganov/llama.cpp/blob/master/.devops/main.Dockerfile)
* [piper Dockerfile](https://github.com/rhasspy/piper/blob/master/Dockerfile)

## Usage

```
docker build -t metatron .
docker run -it metatron

docker run -it --rm -p 8080:8080 metatron
```

Debugging:
```
docker build -t metatron --no-cache .
```
