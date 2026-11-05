import { Request, Response } from 'express';
import authService from './auth.service';
import {
    registerSchema,
    loginSchema,
    refreshTokenSchema,
    logoutSchema,
} from './auth.validation';
import { AuthenticatedRequest } from './auth.types';

export class AuthController {
    async register(req: Request, res: Response) {
        try {
            const validation = registerSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: validation.error.issues.map((issue) => ({
                        field: issue.path.join('.'),
                        message: issue.message,
                    })),
                });
            }

            const user = await authService.register(validation.data);

            return res.status(201).json({
                success: true,
                message: 'Account created successfully',
                data: {
                    user,
                },
            });
        } catch (error) {
            if (
                error instanceof Error &&
                error.message === 'EMAIL_ALREADY_EXISTS'
            ) {
                return res.status(409).json({
                    success: false,
                    message: 'An account with this email already exists',
                });
            }

            console.error('Registration error:', error);

            return res.status(500).json({
                success: false,
                message: 'Something went wrong while creating your account',
            });
        }
    }

    async login(req: Request, res: Response) {
        try {
            const validation = loginSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: validation.error.issues.map((issue) => ({
                        field: issue.path.join('.'),
                        message: issue.message,
                    })),
                });
            }

            const result = await authService.login(validation.data);

            return res.status(200).json({
                success: true,
                message: 'Login successful',
                data: result,
            });
        } catch (error) {
            if (
                error instanceof Error &&
                error.message === 'INVALID_CREDENTIALS'
            ) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid email or password',
                });
            }

            if (
                error instanceof Error &&
                error.message === 'ACCOUNT_INACTIVE'
            ) {
                return res.status(403).json({
                    success: false,
                    message: 'Your account is not active',
                });
            }

            console.error('Login error:', error);

            return res.status(500).json({
                success: false,
                message: 'Something went wrong while logging in',
            });
        }
    }

    async refresh(req: Request, res: Response) {
        try {
            const validation = refreshTokenSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: validation.error.issues.map((issue) => ({
                        field: issue.path.join('.'),
                        message: issue.message,
                    })),
                });
            }

            const result = await authService.refresh(validation.data);

            return res.status(200).json({
                success: true,
                message: 'Token refreshed successfully',
                data: result,
            });
        } catch (error) {
            if (
                error instanceof Error &&
                error.message === 'INVALID_REFRESH_TOKEN'
            ) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid or expired refresh token',
                });
            }

            if (
                error instanceof Error &&
                error.message === 'ACCOUNT_INACTIVE'
            ) {
                return res.status(403).json({
                    success: false,
                    message: 'Your account is not active',
                });
            }

            console.error('Refresh token error:', error);

            return res.status(500).json({
                success: false,
                message: 'Something went wrong while refreshing the token',
            });
        }
    }

    async logout(req: Request, res: Response) {
        try {
            const validation = logoutSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: validation.error.issues,
                });
            }

            await authService.logout(validation.data.refreshToken);

            return res.status(200).json({
                success: true,
                message: 'Logout successful',
            });
        } catch (error) {
            if (
                error instanceof Error &&
                error.message === 'INVALID_REFRESH_TOKEN'
            ) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid refresh token',
                });
            }

            console.error('Logout error:', error);

            return res.status(500).json({
                success: false,
                message: 'Something went wrong while logging out',
            });
        }
    }

    async me(req: AuthenticatedRequest, res: Response) {
        try {
            const user = await authService.getProfile(req.userId!);

            return res.status(200).json({
                success: true,
                data: { user },
            });
        } catch (error) {
            console.error('Profile error:', error);

            return res.status(500).json({
                success: false,
                message: 'Unable to retrieve user profile',
            });
        }
    }

}

export default new AuthController();