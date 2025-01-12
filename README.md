# Original Assignment Readme
# CI/CD Pipelines in GitHub Actions: In-Class Challenge Activity

This activity is designed to introduce students to creating and managing CI/CD pipelines using GitHub Actions. The activity is split into two phases: a guided walkthrough and a timed challenge.

## Phase 1: Guided Walkthrough

### Objective
Set up a CI/CD pipeline for a sample TypeScript project using GitHub Actions.

### Prerequisites
1. A GitHub account.
2. Docker installed on your local machine.
3. Basic understanding of Git, Docker, and TypeScript.

### Steps

#### 1. Clone the Starter Repository
1. Clone the provided starter repository: `git clone https://github.com/example/repo.git`.
2. Navigate to the project directory: `cd repo`.

#### 2. Examine the TypeScript Project
The project includes:
- A basic TypeScript CLI application (see below).
- A `Dockerfile` to containerize the application.
- Unit tests using Jest.

Sample TypeScript Application:

```typescript
// src/index.ts
import express, { Request, Response } from 'express';

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req: Request, res: Response) => {
  res.send('Hello, CI/CD API!');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
```

Add the following scripts to `package.json`:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "test": "jest",
    "dev": "nodemon src/index.ts"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "typescript": "^4.9.0",
    "ts-node": "^10.9.0",
    "nodemon": "^2.0.22",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "lodash": "^4.17.15",
    "ts-jest": "^29.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@types/express": "^4.17.17"
  }
}
```

Add the following to tsconfig.json
```json
{
    "compilerOptions": {
      "target": "ES6",
      "module": "CommonJS",
      "outDir": "./dist",
      "rootDir": "./src",
      "strict": true,
      "esModuleInterop": true
    }
  }
```

#### 3. Set Up GitHub Actions Workflow

##### Jobs Overview
We will create the following jobs in our pipeline:

1. **Lint**: Ensure code quality by checking for linting errors.
2. **Security**: Scan for vulnerabilities in dependencies.
3. **Test**: Run unit tests to verify functionality.
4. **Build**: Build a Docker image for the application.
5. **Push**: Push the Docker image to DockerHub.

##### Writing the Workflow File Step-by-Step

1. **Create the Lint Job**
   - Navigate to `.github/workflows/`.
   - Create a file named `test.yml`.
   - Add the linting step:

```yaml
name: Test Pipeline

on:
  push:
    branches:
      - test

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm ci
      - name: Lint Code
        run: npm run lint
```

2. **Add the Security Job**
   - Add a job to check for vulnerabilities:

```yaml
  security:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm ci
      - name: Check for Vulnerabilities
        run: npm audit
```

3. **Add the Test Job**
   - Add a job to run unit tests:

```yaml
  test:
    runs-on: ubuntu-latest
    needs: security
    steps:
      - uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm ci
      - name: Run Tests
        run: npm test
```

4. **Add the Build Job**
   - Add a job to build the Docker image:

```yaml
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker Image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/typescript-app:test .
```

5. **Add the Push Job**
   - Add a job to push the Docker image to DockerHub:

```yaml
  push:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v3
      - name: Login to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
      - name: Push Docker Image
        run: docker push ${{ secrets.DOCKER_USERNAME }}/typescript-app:test
```

6. **Create the `main` Workflow File**
   - Duplicate the steps above, but modify the `on:` section to trigger on `main` branch pushes
   - Additionally, make sure that the tag of our image is `latest` for the `main` branch workflow.

```yaml
on:
  push:
    branches:
      - main
```

#### 4. Add Secrets and Environment Variables
1. Go to your repository’s **Settings > Secrets and variables > Actions**.
2. Add:
   - `DOCKER_USERNAME`: Your DockerHub username.
   - `DOCKER_PASSWORD`: Your DockerHub password.

#### 5. Test the Pipeline
1. Create and push changes to the `test` branch.
2. Verify the pipeline executes successfully.
3. Merge to the `main` branch and confirm the main workflow runs.

---
