<template>
    <div>
        <div>
            <img src="~/static/images/small-logo.png" width="80" style="padding: 10px;" alt="illustration">
        </div>
        <div class="login-container">
            <div class="row vertical-center-login">
                <div class="col-6 col-md-6 col-sm-12">
                    <img src="~/static/images/login-illustration.svg" alt="image">
                </div>
                <div class="col-6 col-md-6 col-sm-12">
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
            email: null,
            password: null,
        } 
    },
    methods: {
        async loginUser() {
            try {
                const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
                if (!this.email.trim().match(emailRegex)) {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'error',
                        title: 'Enter a valid email.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                    return
                }
                if (!this.password.trim()) {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'error',
                        title: 'Enter a valid password.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                    return
                }
                const resp = await this.$auth.loginWith('local', {
                    data: {
                        email: this.email,
                        password: this.password
                    }
                })
                if (this.$auth.loggedIn) {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'success',
                        title: 'Logged in.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                } else {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'error',
                        title: resp.data.message,
                        showConfirmButton: false,
                        timer: 1500
                    })
                }
            } catch (error) {
                console.log(error);
                console.log(error.message);
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: error.message,
                    showConfirmButton: false,
                    timer: 1500
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