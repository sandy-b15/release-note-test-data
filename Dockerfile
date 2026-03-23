FROM node:22-alpine\nWORKDIR /app\nCOPY . .\nEXPOSE 3000\nCMD ["node","index.js"]
