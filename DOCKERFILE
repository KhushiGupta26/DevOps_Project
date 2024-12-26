FROM node:16-alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --only=production

COPY . .

# The ENV instructions have been removed.  Manage these externally.
# CMD ["npm", "run", "start"]  <- likely incorrect for a production build
CMD ["npm", "run", "build"]  # build the production app for a subsequent step.
# You will likely then copy the build output to an nginx image or another web server.
