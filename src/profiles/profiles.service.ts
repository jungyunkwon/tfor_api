import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient } from '@supabase/supabase-js';

@Injectable()
export class ProfilesService {
    private supabase: any;

    constructor(private configService: ConfigService) {
        const supabaseUrl = this.configService.get<string>('SUPABASE_URL') || '';
        const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY') || '';
        this.supabase = createClient(supabaseUrl, supabaseKey);
    }

    async getMe(userId: string) {
        const { data, error } = await this.supabase
            .from('profiles') // 실제 테이블명은 snake_case 규칙에 따라 확인 필요 (user_profiles 등)
            .select('*')
            .eq('id', userId)
            .single();

        if (error) {
            if (error.code === 'PGRST116') return null; // Not found
            throw new InternalServerErrorException({
                message: 'Database error',
                code: 'E_DB_ERROR',
                details: error,
            });
        }

        return data;
    }

    async updateMe(userId: string, updateData: any) {
        const { data, error } = await this.supabase
            .from('profiles')
            .upsert({ id: userId, ...updateData, updated_at: new Date() })
            .select()
            .single();

        if (error) {
            throw new InternalServerErrorException({
                message: 'Update failed',
                code: 'E_DB_UPDATE_FAILED',
                details: error,
            });
        }

        return data;
    }
}
