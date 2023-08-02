<template>
    <div class="align-items-center container-fluid vertical-center" >
        <div class="p-5 card text-center" style="height: 500px; width: 50% !important;">
            <h3>Forgot password</h3>
            <div class="row align-items-center p-3">
                <label class="col-3" for="Email">Email</label>
                <input class="col-9" type="text" :disabled="otpVerified" name="Email" v-model="email" placeholder="Email">
            </div>
            <div class="align-items-center ">
                <button v-if="!sentOtp && !otpVerified" @click.prevent="createTimer" :disabled="!email && timer != '0 : 0'" :style="!email && timer != '0 : 0' ? 'pointer-events: none' : 'pointer-event: auto'" class="btn2">Send otp</button>
                <p v-if="sentOtp && !otpVerified" style="font-size: 18px; color: rgb(255, 59, 59);">You can resend otp in {{ sec }} sec.</p>
            </div>
            <div class="align-items-center row p-3" v-if="sentOtp && !otpVerified">
                <label class="col-2" for="Otp">Otp</label>
                <input class="col-3" type="number" name="Otp" v-model="otp" placeholder="Otp">
                <div class="col-3">
                    <button class="btn2" @click.prevent="submitOtp">Verify</button>
                </div>
            </div>
            <div class="row p-3 align-items-center" v-if="otpVerified" >
                <label class="col-3" for="newPassword">New Pass</label>
                <input class="col-9" type="text" name="newPassword" v-model="new_pass" placeholder="New Password">
            </div>
            <div class="row p-3 align-items-center" v-if="otpVerified" >
                <label class="col-3" for="confPassword">Confirm Pass</label>
                <input class="col-9" type="text" name="confPassword" v-model="new_cnf_pass" placeholder="Confirm Password">
            </div>
            <div class="align-items-center ">
                <button v-if="otpVerified" @click.prevent="resetPassowrd" class="btn2">Reset</button>
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
            otp: null,
            sentOtp: false,
            otpVerified: false,
            new_pass: null,
            sec: 120,
            new_cnf_pass: null,
        }
    },
    methods: {
        async resetPassowrd() { 
            if (this.new_pass.trim() == '') {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter a valid password.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (this.new_cnf_pass.trim() == '') {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter a valid confirm password.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (this.new_pass != this.new_cnf_pass) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'New password and confirm password has to be same.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            const response = await this.$axios.post('/update-password', {
                email: this.email,
                password: this.new_pass
            })
            if (response.data.message.includes('success')) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'success',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                await this.$auth.loginWith('local', {
                    data: {
                        email: this.email,
                        password: this.new_pass
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
                        title: 'Check your credentials.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                }
            } else {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
            }
        },
        async submitOtp() { 
            if (this.otp.trim().length < 4) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter a valid otp.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            const response = await this.$axios.post('/forgot-password-validate-otp', {
                email: this.email,
                otp: this.otp
            })
            this.otpVerified = response.data.verified
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
        },
        async createTimer() {
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
            const response = await this.$axios.post('/forgot-password-otp', {
                email: this.email
            })
            if (response.data.message.includes('success')) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'success',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.sentOtp = true
                setInterval(() => {
                   this.sec -= 1 
                }, 1000);
                setTimeout(() => {
                    if (!this.otpVerified) {
                        this.sentOtp = false
                    }
                }, 120000);
            } else {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
            }
        }
    }
}
</script>

<style>
.vertical-center {
  min-height: 100%;
  min-height: 100vh; 
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>