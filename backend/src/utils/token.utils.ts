import crypto from 'crypto';
import jwt from 'jsonwebtoken';

export const generateAccessToken = (userId: string): string => {
    const secret = process.env.JWT_ACCESS_SECRET;

    if (!secret) {
        throw new Error('JWT_ACCESS_SECRET is not configured');
    }

    return jwt.sign(
        { sub: userId },
        secret,
        { expiresIn: '15m' },
    );
};

export const generateRefreshToken = (): string => {
    return crypto.randomBytes(64).toString('hex');
};

export const hashToken = (token: string): string => {
    return crypto
        .createHash('sha256')
        .update(token)
        .digest('hex');
};