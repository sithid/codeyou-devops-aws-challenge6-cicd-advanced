import express, { Request, Response } from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req: Request, res: Response) => {
  res.send('Hello, CI/CD API!');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});