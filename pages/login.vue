<template>
    <div class="align-items-center container-fluid vertical-center" >
        <div class="p-5 card text-center" style="height: 500px;">
            <h3>Login</h3>
            <div class="p-3">
                <label for="Email">Email</label>
                <input type="text" name="Email" v-model="email" placeholder="Email">
            </div>
            <div class="p-3">
                <label for="password">Password</label>
                <input type="password" name="password" v-model="password" id="password" placeholder="password">
                <i id="eyeButton" @click.prevent="changePasswordType" class="fa fa-eye-slash"></i>
            </div>
            <div class="p3">
                <button class="btn btn-success" @click.prevent="loginUser">Login</button>
                <!-- <p>Create acount? <a href="/register">Sign up.</a></p> -->
                <!-- <a href="/forgot">Forgot password?</a> -->
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
                await this.$auth.loginWith('local', {
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
                    console.log(this.$auth);
                    Swal.fire({
                        position: 'top-end',
                        icon: 'error',
                        title: 'Check your credentials.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                }
            } catch (error) {
                console.log(error);
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
.vertical-center {
  min-height: 100%;
  min-height: 100vh; 
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>