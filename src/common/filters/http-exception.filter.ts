import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    HttpException,
    HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
    catch(exception: any, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const status =
            exception instanceof HttpException
                ? exception.getStatus()
                : HttpStatus.INTERNAL_SERVER_ERROR;

        const exceptionResponse =
            exception instanceof HttpException
                ? exception.getResponse()
                : { message: 'Internal server error', code: 'E_INTERNAL_SERVER_ERROR' };

        const message = (exceptionResponse as any).message || exception.message;
        const errorCode = (exceptionResponse as any).code || 'E_INTERNAL_SERVER_ERROR';

        response.status(status).json({
            error: {
                code: errorCode,
                message: message,
                details: (exceptionResponse as any).details || null,
            },
        });
    }
}
