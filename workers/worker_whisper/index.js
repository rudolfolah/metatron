const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'metatron',
  brokers: ['kafka:9092']
});
