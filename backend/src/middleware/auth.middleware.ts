import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthenticatedRequest } from '../modules/auth/auth.types';

interface AccessTokenPayload {
    sub: string;
}

export const authenticate = (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
) => {
    try {
        const authorization = req.headers.authorization;

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required',
            });
        }

        const token = authorization.split(' ')[1];
        const secret = process.env.JWT_ACCESS_SECRET;

        if (!secret || !token) {
            return res.status(401).json({
                success: false,
                message: 'Invalid authentication token',
            });
        }

        const decoded = jwt.verify(token, secret) as AccessTokenPayload;

        req.userId = decoded.sub;

        next();
    } catch {
        return res.status(401).json({
            success: false,
            message: 'Invalid or expired access token',
        });
    }
};