import { ConfigService } from '@nestjs/config';
export declare class ProfilesService {
    private configService;
    private supabase;
    constructor(configService: ConfigService);
    getMe(userId: string): Promise<any>;
    updateMe(userId: string, updateData: any): Promise<any>;
}
