<template>
    <div>
        <div>
            <img src="/icons/small-logo.png" width="80" style="padding: 10px;" alt="illustration">
        </div>
        <div class="login-container">
            <div class="row vertical-center-login">
                <div class="col-6 col-md-6 col-sm-12">
                    <img src="/icons/login-Illustration.svg" alt="image">
                </div>
                <div class="col-6 col-md-6 col-sm-12">
                    <div class="login-input-container d-flex flex-row justify-content-center" style="width: 80% !important;">
                        <h1 class="text-heading h1" style="font-size: 35px !important; line-height: 40px !important;">Login</h1>
                    </div>
                    <div class="login-input-container">
                        <span class="login-input-label">Email*</span>
                        <div class="login-input-field">
                            <i class="fa fa-envelope-o"></i>
                            <input type="text" v-model="email" name="email"  placeholder="Email">
                        </div>
                    </div>
                    <div class="login-input-container">
                        <label class="login-input-label" for="password">Password*</label>
                        <div class="login-input-field">
                            <i class="fa fa-key"></i>
                            <input type="password" id="password" v-model="password" name="password"  placeholder="Password">
                            <i @click.prevent="changePasswordType" id="eyeButton" class="fa fa-eye-slash"></i>
                        </div>
                    </div>
                    <button class="login-button" @click.prevent="loginUser"><span>Continue</span></button>
                    <!-- social media logins -->
                    <!-- <div class="break">
                        <div class="line"></div>
                        <span>or</span>
                        <div class="line"></div>
                    </div>
                    <div class="social-media-login">
                        <button class="google-button"><img src="~/static/icons/google.svg" alt="Sign in with Google"><span>Sign in with Google</span></button>
                        <button class="facebook-button"><img src="~/static/icons/facebook.svg" alt="Sign in with Facebook"><span>Sign in with Facebook</span></button>
                        <button class="apple-button"><img src="~/static/icons/apple.svg" alt="Sign in with Apple"><span>Sign in with Apple</span></button>
                    </div> -->
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
export default {
    data() {
        return {
            email: 'debanjan.d@jurysoft.com',
            password: '1234',
        } 
    },
    async mounted() {
        try {
            const token = localStorage.getItem('token')
            if (token) {
                this.$axios.setHeader('Authorization', token)
                const respo = await this.$axios.get('/get-user')
                if (respo.data.status == 'success') {
                    localStorage.setItem('user', JSON.stringify(respo.data.user))
                    this.$router.push('/')
                }
            }
            localStorage.removeItem('token')
            const refreshToken = localStorage.getItem('refreshToken')
            console.log(refreshToken);
            if (refreshToken) {
                const resp = await this.$axios({
                    url: '/get-access-token-admin',
                    method: 'POST',
                    data: {
                        refreshtoken: refreshToken
                    },
                })
                if (resp.data.status == 'success') {
                    localStorage.setItem('token', resp.data.token)
                    localStorage.setItem('refreshToken', resp.data.refreshToken)
                    this.$axios.setHeader('Authorization', resp.data.token)
                    const respo = await this.$axios.get('/get-user')
                    if (respo.data.user == 'Session expired') {
                        localStorage.removeItem('token')
                        // localStorage.removeItem('refreshToken')
                        this.$router.push('/login')
                        return
                    }
                    localStorage.setItem('user', JSON.stringify(respo.data.user))
                    this.$router.push('/')
                }
            }
        } catch (error) {
            console.log(error);
        }
    },
    methods: {
        async loginUser() {
            try {
                const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
                if (!this.email.trim().match(emailRegex)) {
                    this.$toast.show('Enter a valid email.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'info'
                    })
                    return
                }
                if (!this.password.trim()) {
                    this.$toast.show('Enter a valid password.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'info'
                    })
                    return
                }
                const resp = await this.$axios.post('/login-admin', {
                    email: this.email,
                    password: this.password
                })
                if (resp.data.status == 'success') {
                    this.$toast.show('Logged in.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: resp.data.status
                    })
                    localStorage.setItem('token', resp.data.token)
                    localStorage.setItem('refreshToken', resp.data.refreshToken)
                    this.$axios.setHeader('Authorization', resp.data.token)
                    const respo = await this.$axios.get('/get-user')
                    localStorage.setItem('user', JSON.stringify(respo.data.user))
                    this.$router.push('/')
                }
            } catch (error) {
                this.$toast.show(error.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            }
        },
        changePasswordType() {
            const pass = document.getElementById("password")
            pass.setAttribute('type', document.getElementById('eyeButton').classList.contains('fa-eye-slash') ? 'text' : 'password')
            if (document.getElementById('eyeButton').classList.contains('fa-eye-slash')) {
                document.getElementById('eyeButton').classList.remove('fa-eye-slash')
                document.getElementById('eyeButton').classList.add('fa-eye')
            } else {
                document.getElementById('eyeButton').classList.remove('fa-eye')
                document.getElementById('eyeButton').classList.add('fa-eye-slash')
            }
        }
    }
}
</script>

<style>
</style>