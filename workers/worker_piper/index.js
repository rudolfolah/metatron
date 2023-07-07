const http = require("node:http");
const fs = require("node:fs");
const FormData = require("form-data");
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'metatron',
  brokers: ['kafka:9092']
});

async function main() {
  const producer = kafka.producer();
  const consumer = kafka.consumer({ groupId: 'metatron' });
  await producer.connect();
  await consumer.connect();
  await consumer.subscribe({ topic: 'text_to_speech' });
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      if (topic === 'text_to_speech') {
        console.log('Message received from Kafka:', message.value.toString());
        // TODO: send the message to piper and then save the resulting audio file
        // send file to api http://localhost:3000/upload_response
        const form = new FormData();
        form.append('response', fs.createReadStream('package.json'));
        const req = http.request({
          host: 'api',
          port: 3000,
          path: '/upload_response',
          method: 'POST',
          headers: form.getHeaders(),
        });
        form.pipe(req);
        req.on('response', function(res) {
          console.log(res.statusCode);
        });
      }
    }
  })
}

main().catch((err) => {
  console.error(err);
});
