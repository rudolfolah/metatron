const crypto = require("node:crypto");
const fs = require("node:fs");
const { Kafka } = require('kafkajs');
const express = require('express');
const multer = require('multer');

fs.mkdirSync('/tmp/uploads', { recursive: true });
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, '/tmp/uploads')
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
    cb(null, file.fieldname + '-' + uniqueSuffix)
  }
});
const upload = multer({ storage });

const fileIdPathMap = {};

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
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  app.listen(process.env.API_SERVER_PORT, () => {
    console.log(`Server listening on port ${process.env.API_SERVER_PORT}`);
  });

  await consumer.subscribe({ topic: 'completed' });
  await consumer.run({
    eachMessage: async ({ topic, partition, message}) => {
    }
  });

  app.get('/test', async (req, res) => {
    const timestamp = Date.now();
    await producer.send({
      topic: 'text_to_speech',
      messages: [
        { value: 'Hello, world this a test using Kafka to produce a message that is consumed by a worker process.' },
      ],
    });
    console.log(`${timestamp}: Test message sent`);
    res.send({ message: 'Test messages sent', timestamp });
  });

  app.post('/upload_recording', upload.single('recording'), async (req, res) => {
    const uuid = crypto.randomUUID();
    fileIdPathMap[uuid] = req.file.path;
    console.log(`Recording uploaded with id ${uuid} to path ${req.file.path}`);
    res.send(uuid);
  });

  app.post('/upload_response', upload.single('response'), async (req, res) => {
    const uuid = crypto.randomUUID();
    fileIdPathMap[uuid] = req.file.path;
    console.log(`Response uploaded with id ${uuid} to path ${req.file.path}`);
    res.send(uuid);
  });

  app.get('/file/:id', async (req, res) => {
    if (!fileIdPathMap[req.params.id]) {
      console.error(`File not found with id ${req.params.id}`)
      res.status(404).send({ error: 'File not found' });
      return;
    }
    console.log(`Sending file with id ${req.params.id} from path ${fileIdPathMap[req.params.id]}`);
    res.sendFile(fileIdPathMap[req.params.id]);
  });
}

main().then(() => {
  console.log('Done');
}).catch((err) => {
  console.error(err);
});
