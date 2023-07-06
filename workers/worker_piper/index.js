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
  await consumer.subscribe({ topic: 'tts-queue' });
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      if (topic === 'tts-queue') {
        // TODO: send the message to piper and then save the resulting audio file
        console.log('Message received from Kafka:', message.value.toString());
      }
    }
  })
}

main().then(() => {
  console.log('Done');
}).catch((err) => {
  console.error(err);
});
