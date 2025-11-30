<template>
        <div class="login-container">
                <div class="login-bg-shapes">
                        <div class="shape shape-1"></div>
                        <div class="shape shape-2"></div>
                        <div class="shape shape-3"></div>
                        <div class="shape shape-4"></div>
                </div>
                <div class="login-card">
                        <div class="logo-container">
                                <TetrisLogo :size="56" />
                        </div>

                        <h2 class="login-title">TETRISNEWS</h2>
                        <p class="login-subtitle">Plateforme d'emailing professionnelle</p>

                        <n-form ref="formRef" size="large" :model="form" :rules="rules">
                                <n-form-item :show-label="false" path="username">
                                        <n-input v-model:value="form.username" :placeholder="t('login.form.usernamePlaceholder')">
                                                <template #prefix>
                                                        <i class="i-mdi-account-outline text-18px text-gray-400"></i>
                                                </template>
                                        </n-input>
                                </n-form-item>
                                <n-form-item :show-label="false" path="password">
                                        <n-input
                                                v-model:value="form.password"
                                                class="password-input"
                                                type="password"
                                                show-password-on="click"
                                                :placeholder="t('login.form.passwordPlaceholder')"
                                                @keyup.enter="handleLogin">
                                                <template #prefix>
                                                        <i class="i-mdi-lock-outline text-18px text-gray-400"></i>
                                                </template>
                                        </n-input>
                                </n-form-item>
                                <n-form-item v-if="isCode" :show-label="false" path="validate_code">
                                        <n-input
                                                v-model:value="form.validate_code"
                                                class="flex-1"
                                                :placeholder="t('login.form.captcha')"
                                                :input-props="{ spellcheck: false }"
                                                @keydown.enter="handleLogin">
                                                <template #prefix>
                                                        <i class="i-mdi-shield-check-outline text-18px text-gray-400"></i>
                                                </template>
                                        </n-input>
                                        <n-spin size="small" :show="codeLoading">
                                                <div class="code" @click="getCode()">
                                                        <img
                                                                class="w-full h-full"
                                                                :src="codeUrl"
                                                                :title="t('login.form.changeCaptcha')"
                                                                :alt="t('login.form.captcha')" />
                                                </div>
                                        </n-spin>
                                </n-form-item>
                                <n-form-item :show-label="false" :show-feedback="false">
                                        <n-button
                                                type="primary"
                                                size="large"
                                                class="login-btn"
                                                :loading="loading"
                                                :disabled="loading"
                                                :block="true"
                                                @click="handleLogin">
                                                <template #icon>
                                                        <i class="i-mdi-login mr-8px"></i>
                                                </template>
                                                {{ t('login.form.loginButton') }}
                                        </n-button>
                                </n-form-item>
                        </n-form>
                        
                        <div class="login-footer">
                                <span>TETRISNEWS Emailing © 2025</span>
                        </div>
                </div>
        </div>
</template>

<script lang="ts" setup>
import { useUserStore } from '@/store'
import { isObject } from '@/utils'
import { getValidateCode, login } from '@/api/modules/user'
import TetrisLogo from '@/components/common/TetrisLogo.vue'

const { t } = useI18n()

const router = useRouter()
const userStore = useUserStore()

const formRef = useTemplateRef('formRef')

const isCode = ref(false)

const codeUrl = ref('')

const codeLoading = ref(false)

const form = reactive({
        username: '',
        password: '',
        validate_code: '',
        validate_code_id: '',
})

const rules = {
        username: {
                required: true,
                message: t('login.validation.usernameRequired'),
                trigger: ['blur', 'input'],
        },
        password: {
                required: true,
                message: t('login.validation.passwordRequired'),
                trigger: ['blur', 'input'],
        },
        validate_code: {
                required: true,
                trigger: ['blur', 'input'],
                message: t('login.validation.captchaRequired'),
        },
}

interface CodeResponse {
        mustValidateCode: boolean
        validateCodeBase64: string
        validateCodeId: string
}

const getCode = async () => {
        try {
                codeLoading.value = true
                const res = await getValidateCode()
                if (isObject<CodeResponse>(res)) {
                        isCode.value = res.mustValidateCode
                        if (res.mustValidateCode) {
                                codeUrl.value = res.validateCodeBase64
                                form.validate_code_id = res.validateCodeId
                        }
                }
        } finally {
                codeLoading.value = false
        }
}

const loading = ref(false)

interface LoginResponse {
        token: string
        refresh_token: string
        ttl: number
}

const handleLogin = async () => {
        try {
                await formRef.value?.validate()
                loading.value = true
                const res = await login(toRaw(form))
                if (isObject<LoginResponse>(res)) {
                        userStore.setLoginInfo({
                                token: res.token,
                                refresh_token: res.refresh_token,
                                ttl: res.ttl,
                        })
                        setTimeout(() => {
                                router.push('/')
                        }, 1000)
                }
        } catch {
                getCode()
        } finally {
                loading.value = false
        }
}

getCode()
</script>

<style lang="scss" scoped>
.login-container {
        display: flex;
        position: relative;
        justify-content: center;
        align-items: center;
        min-height: 100%;
        background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 40%, #2563eb 100%);
        overflow: hidden;
}

.login-bg-shapes {
        position: absolute;
        inset: 0;
        overflow: hidden;
        pointer-events: none;
}

.shape {
        position: absolute;
        border-radius: 50%;
        opacity: 0.08;
        background: white;
}

.shape-1 {
        top: -15%;
        right: -10%;
        width: 600px;
        height: 600px;
        animation: float 25s ease-in-out infinite;
}

.shape-2 {
        bottom: -20%;
        left: -15%;
        width: 700px;
        height: 700px;
        animation: float 30s ease-in-out infinite reverse;
}

.shape-3 {
        top: 30%;
        left: 10%;
        width: 250px;
        height: 250px;
        animation: float 18s ease-in-out infinite;
}

.shape-4 {
        bottom: 20%;
        right: 15%;
        width: 180px;
        height: 180px;
        animation: float 22s ease-in-out infinite reverse;
}

@keyframes float {
        0%, 100% {
                transform: translateY(0) rotate(0deg);
        }
        50% {
                transform: translateY(-40px) rotate(5deg);
        }
}

.login-card {
        width: 100%;
        max-width: 440px;
        background: rgba(255, 255, 255, 0.98);
        padding: 48px 44px;
        border-radius: 24px;
        box-shadow: 
                0 25px 60px -15px rgba(0, 0, 0, 0.35),
                0 0 0 1px rgba(255, 255, 255, 0.1);
        z-index: 1;
        backdrop-filter: blur(20px);
}

.logo-container {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 16px;
}

.login-title {
        margin: 12px 0 4px;
        text-align: center;
        font-weight: 800;
        font-size: 28px;
        color: #1e293b;
        letter-spacing: 1px;
}

.login-subtitle {
        margin: 0 0 36px;
        text-align: center;
        font-size: 14px;
        color: #64748b;
        font-weight: 400;
}

.login-btn {
        height: 50px;
        font-weight: 600;
        font-size: 15px;
        border-radius: 12px;
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        border: none;
        box-shadow: 0 4px 14px rgba(37, 99, 235, 0.4);
        transition: all 0.3s ease;
        
        &:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(37, 99, 235, 0.5);
        }
        
        &:active {
                transform: translateY(0);
        }
}

.code {
        width: 120px;
        height: 42px;
        margin-left: 12px;
        border-radius: 10px;
        border: 1px solid #e2e8f0;
        overflow: hidden;
        cursor: pointer;
        transition: all 0.2s ease;
        
        &:hover {
                border-color: #3b82f6;
                box-shadow: 0 2px 8px rgba(59, 130, 246, 0.2);
        }
}

.login-footer {
        margin-top: 36px;
        text-align: center;
        font-size: 12px;
        color: #94a3b8;
        font-weight: 500;
}

:deep(.n-input) {
        --n-height: 50px;
        --n-border-radius: 12px;
        --n-font-size: 15px;
        --n-border: 1px solid #e2e8f0;
        --n-border-hover: 1px solid #3b82f6;
        --n-border-focus: 1px solid #2563eb;
        --n-box-shadow-focus: 0 0 0 4px rgba(37, 99, 235, 0.12);
        --n-caret-color: #2563eb;
}

:deep(.n-form-item) {
        --n-feedback-font-size: 13px;
        margin-bottom: 20px;
}
</style>