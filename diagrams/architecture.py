from diagrams import Diagram, Cluster
from diagrams.aws.network import VPC, PublicSubnet, PrivateSubnet, InternetGateway, NATGateway, RouteTable
from diagrams.onprem.network import Internet
with Diagram("AWS VPC Architecture", show=True):

    internet = Internet("Internet")

    with Cluster("VPC (10.0.0.0/16)"):
        igw = InternetGateway("IGW")

        with Cluster("Public Subnets (us-east-1a)"):
            pub1 = PublicSubnet("Public Subnet 1")
            pub2 = PublicSubnet("Public Subnet 2")
            nat = NATGateway("NAT Gateway")

        with Cluster("Private Subnets (us-east-1b)"):
            priv1 = PrivateSubnet("Private Subnet 1")
            priv2 = PrivateSubnet("Private Subnet 2")

        public_rt = RouteTable("Public RT")
        private_rt = RouteTable("Private RT")

    # Connections
    internet >> igw
    igw >> pub1
    igw >> pub2

    pub1 >> nat
    nat >> priv1
    nat >> priv2

    pub1 >> public_rt
    pub2 >> public_rt

    priv1 >> private_rt
    priv2 >> private_rt