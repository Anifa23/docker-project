# Docker Challenge: Dockerize the Todo App

**Objective:** Containerize a full-stack application by writing a multi-stage `Dockerfile` and a `compose.yaml` from scratch, combining a React frontend, a Node.js backend, and a MySQL database into a working multi-container setup with proper networking, data persistence, and live code syncing.

### **Getting Started: Use Template & Clone the Repository**

**Step 1. Create a repository from the template**

- Go to the repository on GitHub: https://github.com/mutesialine/sparc-cloud-docker-project
- Click **Use this template** (top right)
- Create a new repository under your own GitHub account

### **Step 2. Clone your new repository**

- Copy the repository URL from your newly created repo
- Run: `git clone YOUR_REPOSITORY_URL` 

### Part 1: The Dockerfile

##### Instructions

###### Step 1. Containerize the backend

- Write a `Dockerfile` that builds and runs the Node.js backend.
- The server should start and be reachable on port `3000`.

**Verify:** Build the image and hit `http://localhost:3000/api/items` — you should get a JSON response.

###### Step 2. Handle the project's npm security setting

- Check the `.npmrc` file at the root of the project. Understand what it does and why it might cause a problem during the build.
- Make sure your Dockerfile still produces a working image despite this setting.

****Verify:**** The backend starts without any dependency errors in the logs.

###### Step 3. Separate development and production builds
  
- Restructure your Dockerfile so you have a dedicated development image and a lean production image.  
  
- The production image should only contain what's needed to run the app — not dev tools or test files.  
  
****Verify:**** Build both images and compare their sizes with `docker images`.

###### Step 4. Bundle the frontend into the production image
  
- Extend your Dockerfile to also build the React frontend.  
  
- The compiled frontend assets should end up being served by the backend in the production image.  
  
****Verify:**** Run the production image and open `http://localhost:3000` — you should see the full todo app UI, not just the API.  
  
###### Step 5. Make tests a required step before production
  
- The backend has a test suite. Add a stage that runs the tests.  
  
- Wire it up so the production image cannot be built if the tests fail.  
  
****Verify:**** Break a test intentionally — the production build should fail. Fix it, and it should pass again.

### Part 2: The Compose File

#### Instructions

##### Step1. Define your services

- Write a `compose.yaml` that runs the backend and connects it to a MySQL database.
- The backend needs database credentials passed in as environment variables — check `backend/src/persistence/index.js` to see what it expects.

****Verify:**** Run `docker compose up` and confirm the backend connects to MySQL successfully.

##### Step 2. Make the database reliable

- MySQL takes a few seconds to be ready after the container starts. Make sure the backend doesn't crash while waiting for it.
- Persist the database data so it survives a `docker compose down` and back up.

****Verify:**** Add a todo item, run `docker compose down`, then `docker compose up` Again, your item should still be there.

##### Step 3. Add the frontend as a service

- Add the React dev server as a service.
- Set up live code syncing so that changes to source files are reflected in the running containers without a full rebuild.

****Verify:**** Run `docker compose up --watch`, edit a file in `client/src/`, and confirm the change appears in the browser automatically.

##### Step 4. Route frontend and backend through a single port

- In development, the frontend runs on port `5173` and the backend on port `3000`. Add a reverse proxy (Traefik) so both are accessible from port `80`, with requests to `/api/*` going to the backend and everything else going to the frontend.

> 💡 Don't spend too long on this one if you're unfamiliar with Traefik — check the docs or ask a coach.

****Verify:****
- `http://localhost` → React app
- `http://localhost/api/items` → JSON from the backend

#####  Step 5. Add a database UI

- Add phpMyAdmin as a service so you can inspect the database through a browser.
- It should be accessible at `http://db.localhost` (not `http://localhost`).

****Verify:**** Open `http://db.localhost` and confirm you can see the `todos` database and its data.

## Final Check before submitting

```bash

# Development stack with live reload

docker compose up --watch

```

- `http://localhost` → todo app
- `http://db.localhost` → phpMyAdmin

```bash

# Production build

docker build --target final -t todo-app-prod .

docker run -p 3000:3000 todo-app-prod

```

- `http://localhost:3000` → fully bundled app, frontend and backend together

 