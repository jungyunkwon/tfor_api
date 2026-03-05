"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfilesService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const supabase_js_1 = require("@supabase/supabase-js");
let ProfilesService = class ProfilesService {
    configService;
    supabase;
    constructor(configService) {
        this.configService = configService;
        const supabaseUrl = this.configService.get('SUPABASE_URL') || '';
        const supabaseKey = this.configService.get('SUPABASE_ANON_KEY') || '';
        this.supabase = (0, supabase_js_1.createClient)(supabaseUrl, supabaseKey);
    }
    async getMe(userId) {
        const { data, error } = await this.supabase
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .single();
        if (error) {
            if (error.code === 'PGRST116')
                return null;
            throw new common_1.InternalServerErrorException({
                message: 'Database error',
                code: 'E_DB_ERROR',
                details: error,
            });
        }
        return data;
    }
    async updateMe(userId, updateData) {
        const { data, error } = await this.supabase
            .from('profiles')
            .upsert({ id: userId, ...updateData, updated_at: new Date() })
            .select()
            .single();
        if (error) {
            throw new common_1.InternalServerErrorException({
                message: 'Update failed',
                code: 'E_DB_UPDATE_FAILED',
                details: error,
            });
        }
        return data;
    }
};
exports.ProfilesService = ProfilesService;
exports.ProfilesService = ProfilesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], ProfilesService);
//# sourceMappingURL=profiles.service.js.map