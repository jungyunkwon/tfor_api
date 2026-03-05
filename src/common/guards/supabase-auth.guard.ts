import {
    Injectable,
    CanActivate,
    ExecutionContext,
    UnauthorizedException,
} from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
    constructor(private configService: ConfigService) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const authHeader = request.headers.authorization;

        if (!authHeader) {
            throw new UnauthorizedException({
                message: 'Missing authorization header',
                code: 'E_AUTH_NO_HEADER',
            });
        }

        const token = authHeader.split(' ')[1];
        const supabaseUrl = this.configService.get<string>('SUPABASE_URL') || '';
        const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY') || '';

        const supabase = createClient(supabaseUrl, supabaseKey);
        const {
            data: { user },
            error,
        } = await supabase.auth.getUser(token);

        if (error || !user) {
            throw new UnauthorizedException({
                message: 'Invalid or expired token',
                code: 'E_AUTH_INVALID_TOKEN',
            });
        }

        request.user = user;
        return true;
    }
}
