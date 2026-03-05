import { Controller, Get, Put, Body, UseGuards, Request } from '@nestjs/common';
import { ProfilesService } from './profiles.service';
import { SupabaseAuthGuard } from '../common/guards/supabase-auth.guard';

@Controller('profiles')
@UseGuards(SupabaseAuthGuard)
export class ProfilesController {
    constructor(private readonly profilesService: ProfilesService) { }

    @Get('me')
    async getMe(@Request() req) {
        const user = req.user;
        return this.profilesService.getMe(user.id);
    }

    @Put('me')
    async updateMe(@Request() req, @Body() updateData: any) {
        const user = req.user;
        return this.profilesService.updateMe(user.id, updateData);
    }
}
