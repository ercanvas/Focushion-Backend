# 1. Aşama: Build ortamı
FROM node:18-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY prisma ./prisma/
RUN npx prisma generate
COPY . .

# 2. Aşama: Çalıştırma ortamı
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma
# Derleme yoksa tüm klasörü kopyala
COPY --from=builder /app ./ 

# Render 10000 portunu bekliyor
EXPOSE 10000

# MİGRATE KOMUTUNU BURAYA EKLEDİK:
# Uygulama başlamadan önce migrate eder, sonra uygulamayı başlatır.
CMD ["sh", "-c", "npx prisma migrate deploy && node index.js"]