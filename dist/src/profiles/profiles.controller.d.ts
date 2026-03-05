import { ProfilesService } from './profiles.service';
export declare class ProfilesController {
    private readonly profilesService;
    constructor(profilesService: ProfilesService);
    getMe(req: any): Promise<any>;
    updateMe(req: any, updateData: any): Promise<any>;
}
