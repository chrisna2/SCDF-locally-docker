# Docker Compose를 사용한 Spring Cloud Data Flow 로컬 머신 설치


이 저장소는 Docker Compose를 사용하여 로컬 컴퓨터에서 Spring Cloud Data Flow(SCDF)를 쉽게 설정할 수 있는 방법을 제공, 
제공된 구성 파일을 사용하면 SCDF를 실행하는 데 필요한 서비스를 빠르게 시작할 수 있으며, 
데이터 처리 파이프라인의 개발 및 테스트를 바로 시작할 수 있다.

## 사전 요구 사항

- Docker (window, Docker Desktop) 설치
- Docker Compose 설치
- Git (optional, for cloning the repository)
- (WIMDOWS) GNU Make (http://gnuwin32.sourceforge.net/packages/make.htm) - 설치 후 환경 변수(path) 설정 필요

## 빠른 설치 진행

1. 해당 주소의 Git repository에서 clone 진행:

```bash
git clone https://github.com/chrisna2/SCDF-locally-docker.git
```

2. 인텔리J 사용시 Terminal 오픈, PowerShell이 아닌 리눅스 계열 터미널 사용. GIT을 설치한 경우 git Bash 활용 권장
   (이유는 makefile이 리눅스 기반의 명령어로 구성됨) 


3. 프로젝트 디렉터리 경로 변경
```bash
cd SCDF-locally-docker
```

4. 데이터 플로우 환경 서비스 시작, 아래 명령어 실행 :

```bash
make dataflow
```

5. 서비스가 시작될 때까지 기다린 후, SCDF 대시보드에 접속 http://localhost:9393/dashboard.

6. 데이터 플로우 환경 서비스 종료, 아래 명령어 실행 :

```bash
make dataflow-down
```

## 설정

환경 변수를 config.env 파일과 Docker Compose 파일에서 수정하여 설정을 사용자 정의할 수 있다. 
예컨데 , DATAFLOW_VERSION 및 SKIPPER_VERSION 변수를 업데이트하여 SCDF와 Skipper 버전을 변경할 수 있다.

## 서비스

이 설정에는 다음 서비스들이 포함:

* `dataflow-server`: Spring Cloud Data Flow 서버
* `skipper-server`: Spring Cloud Skipper 서버
* `app-import-stream`: Stream 애플리케이션을 가져오기 위한 유틸리티 컨테이너
* `app-import-task`: Task 애플리케이션을 가져오기 위한 유틸리티 컨테이너

## SCDF 서버의 구성

1. Data Flow Server (dataflow-server) :
   Data Flow Server는 애플리케이션 및 데이터 파이프라인을 정의하고 관리하는 역할을 담당. 사용자와의 상호작용을 위한 대시보드와 API를 제공하며, 파이프라인과 애플리케이션의 상태를 모니터링.

   - 어플리케이션 관리: Data Flow Server는 주로 사용자 인터페이스와 REST API를 통해 파이프라인과 애플리케이션을 관리. 여기서 파이프라인을 정의하고, 이를 배포 및 모니터링함.
   - 파이프라인 정의: 사용자 또는 개발자는 Data Flow Server를 통해 스트림 애플리케이션(데이터 처리 애플리케이션)과 작업 애플리케이션(배치 처리 애플리케이션)을 정의함.
   - 애플리케이션 등록: 애플리케이션이 Data Flow Server에 등록되어야 하며, 이를 통해 실행할 스트림과 작업을 구성할 수 있음.
   - 대시보드와 모니터링: 웹 대시보드와 API를 통해 파이프라인 상태를 모니터링하고, 데이터 흐름을 시각적으로 관리함.


- 주요 기능:
  - 사용자 인터페이스 제공
  - REST API를 통한 애플리케이션 관리 및 배포
  - 데이터 파이프라인 구성 및 관리
  - ##### 배치 서비스에 진행 상황 모니터링 및 작업 제어 (본 연구과제의 목적)

2. Skipper Server (skipper-server) :
   Skipper Server는 실제 애플리케이션 배포와 관리를 담당. Data Flow Server에서 정의된 파이프라인을 실제 클러스터에 배포하고, 애플리케이션 버전 관리 및 배포 작업을 처리.

   - 배포 관리: Skipper Server는 주로 애플리케이션의 배포를 담당. Data Flow Server에서 정의된 파이프라인을 실제로 실행하기 위해 Skipper Server가 필요.
   - 버전 관리: Skipper는 애플리케이션 버전 관리를 통해, 다양한 버전의 애플리케이션을 관리하고 배포 가능.
   - 배포의 세부 관리: 애플리케이션을 클러스터에 배포하고, 배포 상태를 모니터링하며, 롤백과 같은 작업을 처리.

- 주요 기능:
  - 애플리케이션의 배포와 관리
  - 애플리케이션 버전 관리
  - 배포 작업의 세부 관리 및 롤백


## SCDF 서버, Spring batch 연동


1. Spring Batch Job 샘플 

```java
@Configuration
@EnableBatchProcessing
public class BatchConfiguration {

    @Autowired
    public JobBuilderFactory jobBuilderFactory;

    @Autowired
    public StepBuilderFactory stepBuilderFactory;

    @Bean
    public Job sampleJob() {
        return jobBuilderFactory.get("sampleJob")
                .incrementer(new RunIdIncrementer())
                .flow(sampleStep())
                .end()
                .build();
    }

    @Bean
    public Step sampleStep() {
        return stepBuilderFactory.get("sampleStep")
                .<String, String>chunk(10)
                .reader(sampleReader())
                .processor(sampleProcessor())
                .writer(sampleWriter())
                .build();
    }

    @Bean
    public ItemReader<String> sampleReader() {
        return new SampleReader();
    }

    @Bean
    public ItemProcessor<String, String> sampleProcessor() {
        return new SampleProcessor();
    }

    @Bean
    public ItemWriter<String> sampleWriter() {
        return new SampleWriter();
    }
}
```


2. Spring Cloud Task로 변환 Sample
```java
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.task.configuration.EnableTask;

@SpringBootApplication
@EnableTask
public class SpringBatchTaskApplication implements CommandLineRunner {

    @Autowired
    private JobLauncher jobLauncher;

    @Autowired
    private Job hpfDownloadJob;

    public static void main(String[] args) {
        SpringApplication.run(SpringBatchTaskApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        jobLauncher.run(hpfDownloadJob, new JobParameters());
        System.out.println("Spring Cloud Task is running!");
    }
}
```

3. Docker 이미지 빌드


```Dockerfile
FROM openjdk:11-jre-slim
VOLUME /tmp
COPY target/your-app.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

```bash
docker build -t my-spring-batch-task .
docker tag my-spring-batch-task username/my-spring-batch-task
docker push username/my-spring-batch-task
```

※ 각 배치 작업을 관리하는 방법:
이미 만들어둔 job이 10개면 그 10개에 대한 이미지나 jar파일을 구성해댜 되는 번거로움이 있음


Docker 이미지 방식
> 개별 Docker 이미지 생성: 각 배치 작업을 별도의 Docker 이미지로 빌드
예를 들어, 각 배치 작업에 대해 개별 Dockerfile을 만들고 이미지를 생성.
```bash
##배치 작업 1: 
docker build -t my-batch-job-1 .
##배치 작업 2: 
docker build -t my-batch-job-2 .
##...
##배치 작업 10: 
docker build -t my-batch-job-10 .
```

JAR 파일 방식
> 개별 JAR 파일 생성: 각 배치 작업을 별도의 JAR 파일로 빌드
SCDF에 배포할 때, 각 JAR 파일을 참조하여 Task를 등록
```bas
##배치 작업 1: 
mvn clean package로 batch-job-1.jar 생성
##배치 작업 2: 
mvn clean package로 batch-job-2.jar 생성
##...
##배치 작업 10: 
mvn clean package로 batch-job-10.jar 생성
````


4. SCDF에 Task 등록 
```bash
dataflow:>task create my-task --definition "docker:username/my-spring-batch-task"
dataflow:>task launch my-task
```

