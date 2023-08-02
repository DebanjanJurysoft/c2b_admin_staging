<template>
    <div class="align-items-center container-fluid vertical-center" >
        <div class="p-5 card text-center" style="height: 500px;">
            <h3>Register</h3>
            <div class="p-3">
                <label for="fullname">Fullname</label>
                <input type="text" name="fullname" placeholder="fullname">
            </div>
            <div class="p-3">
                <label for="username">Username</label>
                <input type="text" name="username" placeholder="Username">
            </div>
            <div class="p-3">
                <label for="password">Password</label>
                <input type="password" name="password" id="password" placeholder="password">
                <i id="eyeButton1" @click.prevent="changePasswordType('password', 1)" class="fa fa-eye-slash"></i>
            </div>
            <div class="p-3">
                <label for="cpassword">Confirm Password</label>
                <input type="password" name="cpassword" id="cpassword" placeholder="Confirm password">
                <i id="eyeButton2" @click.prevent="changePasswordType('cpassword', 2)" class="fa fa-eye-slash"></i>
            </div>
            <div class="p3">
                <button class="btn2">Register</button>
                <p>Already have acount? <a href="/login">Sign in.</a></p>
                <!-- <a href="/forgot">Forgot password?</a> -->
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() { },
    methods: {
        changePasswordType(field, btn) {
            const pass = document.getElementById(field)
            pass.setAttribute('type', document.getElementById('eyeButton'+btn).classList.contains('fa-eye-slash') ? 'text' : 'password')
            if (document.getElementById('eyeButton'+btn).classList.contains('fa-eye-slash')) {
                document.getElementById('eyeButton'+btn).classList.remove('fa-eye-slash')
                document.getElementById('eyeButton'+btn).classList.add('fa-eye')
            } else {
                document.getElementById('eyeButton'+btn).classList.remove('fa-eye')
                document.getElementById('eyeButton'+btn).classList.add('fa-eye-slash')
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