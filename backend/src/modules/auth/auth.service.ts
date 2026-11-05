import bcrypt from 'bcrypt';
import prisma from '../../config/database';
import { RegisterInput } from './auth.validation';
import {
    generateAccessToken,
    generateRefreshToken,
    hashToken,
} from '../../utils/token.utils';

import {
    RefreshTokenInput,
} from './auth.validation';

import { LoginInput } from './auth.validation';
export class AuthService {
    async register(data: RegisterInput) {
        const existingUser = await prisma.user.findUnique({
            where: {
                email: data.email,
            },
        });

        if (existingUser) {
            throw new Error('EMAIL_ALREADY_EXISTS');
        }

        const hashedPassword = await bcrypt.hash(data.password, 12);

        const user = await prisma.user.create({
            data: {
                name: data.name,
                email: data.email,
                password: hashedPassword,
            },
            select: {
                id: true,
                name: true,
                email: true,
                status: true,
                createdAt: true,
            },
        });

        return user;
    }

    async login(data: LoginInput) {
        const user = await prisma.user.findUnique({
            where: {
                email: data.email,
            },
        });

        if (!user) {
            throw new Error('INVALID_CREDENTIALS');
        }

        const passwordMatches = await bcrypt.compare(
            data.password,
            user.password,
        );

        if (!passwordMatches) {
            throw new Error('INVALID_CREDENTIALS');
        }

        if (user.status !== 'ACTIVE') {
            throw new Error('ACCOUNT_INACTIVE');
        }

        const accessToken = generateAccessToken(user.id);
        const refreshToken = generateRefreshToken();
        const refreshTokenHash = hashToken(refreshToken);

        const refreshTokenExpiresInDays = 30;

        const expiresAt = new Date();
        expiresAt.setDate(
            expiresAt.getDate() + refreshTokenExpiresInDays,
        );

        await prisma.session.create({
            data: {
                userId: user.id,
                refreshTokenHash,
                expiresAt,
            },
        });

        return {
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                status: user.status,
            },
            accessToken,
            refreshToken,
            tokenType: 'Bearer',
            expiresIn: 900,
        };
    }

    async refresh(data: RefreshTokenInput) {
        const oldTokenHash = hashToken(data.refreshToken);

        const session = await prisma.session.findUnique({
            where: {
                refreshTokenHash: oldTokenHash,
            },
            include: {
                user: true,
            },
        });

        if (
            !session ||
            session.revokedAt ||
            session.expiresAt <= new Date()
        ) {
            throw new Error('INVALID_REFRESH_TOKEN');
        }

        if (session.user.status !== 'ACTIVE') {
            throw new Error('ACCOUNT_INACTIVE');
        }

        const newAccessToken = generateAccessToken(session.userId);
        const newRefreshToken = generateRefreshToken();
        const newRefreshTokenHash = hashToken(newRefreshToken);

        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 30);

        // Atomically rotate the refresh token.
        const updated = await prisma.session.updateMany({
            where: {
                id: session.id,
                refreshTokenHash: oldTokenHash,
                revokedAt: null,
                expiresAt: {
                    gt: new Date(),
                },
            },
            data: {
                refreshTokenHash: newRefreshTokenHash,
                expiresAt,
            },
        });

        if (updated.count !== 1) {
            throw new Error('INVALID_REFRESH_TOKEN');
        }

        return {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            tokenType: 'Bearer',
            expiresIn: 900,
        };
    }

    async logout(refreshToken: string) {
        const refreshTokenHash = hashToken(refreshToken);

        const result = await prisma.session.updateMany({
            where: {
                refreshTokenHash,
                revokedAt: null,
            },
            data: {
                revokedAt: new Date(),
            },
        });

        if (result.count === 0) {
            throw new Error('INVALID_REFRESH_TOKEN');
        }

        return true;
    }
    async getProfile(userId: string) {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                name: true,
                email: true,
                status: true,
                createdAt: true,
            },
        });

        if (!user || user.status !== 'ACTIVE') {
            throw new Error('USER_NOT_FOUND');
        }

        return user;
    }
}

export default new AuthService();


