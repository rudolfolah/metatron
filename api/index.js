const { Kafka } = require('kafkajs');
const express = require('express');

const kafka = new Kafka({
  clientId: 'metatron',
  brokers: ['kafka:9092']
});

async function main() {
  const producer = kafka.producer();
  const consumer = kafka.consumer({ groupId: 'metatron' });
  await producer.connect();
  await consumer.connect();

  const app = express();
  app.listen(process.env.API_SERVER_PORT, () => {
    console.log(`Server listening on port ${process.env.API_SERVER_PORT}`);
  });

  app.get('/test', async (req, res) => {
    await producer.send({
      topic: 'tts',
      messages: [
        { value: 'Hello, world this a test using Kafka to produce a message that is consumed by a worker process.' },
      ],
    });
    res.send({ message: 'Test messages sent' });
  });
}

main().then(() => {
  console.log('Done');
}).catch((err) => {
  console.error(err);
});
