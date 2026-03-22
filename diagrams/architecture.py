from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import PublicSubnet, PrivateSubnet, InternetGateway, NATGateway, RouteTable
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.onprem.network import Internet

with Diagram("Production VPC Architecture - Ournetwork", show=True, direction="TB"):

    internet = Internet("Internet")

    with Cluster("VPC - Ournetwork (10.0.0.0/16)\nEnvironment: Production"):
        
        igw = InternetGateway("Internet Gateway")
        
        with Cluster("Availability Zone: us-east-1a"):
            
            with Cluster("Public Subnet 1\n10.0.0.0/24"):
                pub1 = PublicSubnet("Public Subnet 1")
                nat = NATGateway("NAT Gateway\n+ Elastic IP")
                web1 = EC2("Web Server\n(Web SG)")
            
            with Cluster("Private Subnet 1\n10.0.10.0/24"):
                priv1 = PrivateSubnet("Private Subnet 1")
                db1 = RDS("Database\n(DB SG)")
        
        with Cluster("Availability Zone: us-east-1b"):
            
            with Cluster("Public Subnet 2\n10.0.1.0/24"):
                pub2 = PublicSubnet("Public Subnet 2")
                web2 = EC2("Web Server\n(Web SG)")
            
            with Cluster("Private Subnet 2\n10.0.11.0/24"):
                priv2 = PrivateSubnet("Private Subnet 2")
                db2 = RDS("Database\n(DB SG)")
        
        # Route Tables
        with Cluster("Route Tables"):
            public_rt = RouteTable("Public RT\n0.0.0.0/0 → IGW")
            private_rt = RouteTable("Private RT\n0.0.0.0/0 → NAT")

    # Internet → IGW → Public Subnets
    internet >> Edge(label="Inbound Traffic") >> igw
    igw >> Edge(label="Route: 0.0.0.0/0") >> pub1
    igw >> Edge(label="Route: 0.0.0.0/0") >> pub2

    # Public Subnets → Route Table Association
    pub1 >> Edge(style="dotted", color="blue") >> public_rt
    pub2 >> Edge(style="dotted", color="blue") >> public_rt

    # NAT Gateway setup (in Public Subnet 1)
    nat >> Edge(label="Deployed in") >> pub1

    # Private Subnets → NAT → Internet
    priv1 >> Edge(label="Outbound Only", color="orange") >> nat
    priv2 >> Edge(label="Outbound Only", color="orange") >> nat
    nat >> Edge(label="via IGW") >> igw

    # Private Subnets → Route Table Association
    priv1 >> Edge(style="dotted", color="green") >> private_rt
    priv2 >> Edge(style="dotted", color="green") >> private_rt

    # Security Group relationships
    web1 >> Edge(label="MySQL/PostgreSQL\n(SG Rule)", color="red") >> db1
    web2 >> Edge(label="MySQL/PostgreSQL\n(SG Rule)", color="red") >> db2