node("linux") {
   def app
   stage('Clone repository') {
       checkout scm
   }

   stage('Build image') {
       app = docker.build("cheisr/os_project", "python_app/")
   }

   stage('Test container') {
       response = app.withRun("-p 8080:5000"){
           sh(script: "sleep 10; curl 127.0.0.1:8080", returnStdout: true)
       }
   }

   stage('Push image') {

       withDockerRegistry(registry:[
               url: '',
               credentialsId: 'dockerhub.cheisr'
               ]){
           app.push()
       }
   }
}
