import java.io.*;
import java.util.*;
import java.sql.*;
import java.util.regex.*;

public class Project3
{
	static final String DRIVER = "oracle.jdbc.OracleDriver";
	static final String URL = "jdbc:oracle:thin:@claros.cs.purdue.edu:1524:strep";

	static final String UNAME = "kahlonr";
	static final String PASS = "basketball3298";

	static String currUser = null;
	static Connection conn = null;
	static Statement statement = null;

	private static final Pattern PARSEQUOTES = Pattern.compile("'(.+?)'");

	final static String uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	final static String lowercase = "abcdefghijklmnopqrstuvwxyz";

	public static void main (String [] args)
	{
		if(args.length <= 1)
		{
			System.out.println("Usage: java -cp .:ojdbc8.jar Project3 input.txt output.txt");
			return;
		}

		try
		{
			FileInputStream fstream = new FileInputStream(args[0]);
			DataInputStream input = new DataInputStream(fstream);
			BufferedReader buf = new BufferedReader(new InputStreamReader(input));
			PrintStream output = new PrintStream(new FileOutputStream(args[1]));
			System.setOut(output);
			Class.forName(DRIVER);
			conn = DriverManager.getConnection(URL, UNAME, PASS);

			String cmd;
			int count = 1; //number of commands run (default 1)
			while((cmd = buf.readLine()) != null)
			{
				String [] tok = cmd.split("\\s+(?![^\\(]*\\))");
				System.out.printf("%d: %s\n", count, cmd);

				switch(tok[0])
				{
					case "LOGIN":
						login(tok);
						System.out.println();
						break;
					case "CREATE":
						switch(tok[1])
						{
							case "ROLE":
								if(currUser.equals("admin"))
								{
									createRole(tok);
									System.out.println("Role created successfully");
									System.out.println();
								}
								else
								{
									System.out.println("Authorization failure");
									System.out.println();
								}
								break;
							case "USER":
								if(currUser.equals("admin"))
								{
									createUser(tok);
									System.out.println("User created successfully");
									System.out.println();
								}
								else
								{
									System.out.println("Authorization failure");
									System.out.println();
								}
								break;
						}
						break;
					case "ASSIGN":
						if(tok[1].equals("ROLE"))
						{
							if(currUser.equals("admin"))
							{
								assignRole(tok);
								System.out.println("Role assigned successfully");
								System.out.println();
							}
							else
							{
								System.out.println("Authorization failure");
								System.out.println();
							}
						}
						break;
					case "GRANT":
						if(tok[1].equals("PRIVILEGE"))
						{
							if(currUser.equals("admin"))
							{
								grantPrivilege(tok);
								System.out.println("Privilege granted successfully");
								System.out.println();
							}
							else
							{
								System.out.println("Authorization failure");
								System.out.println();
							}
						}
						break;
					case "REVOKE":
						if(tok[1].equals("PRIVILEGE"))
						{
							if(currUser.equals("admin"))
							{
								revokePrivilege(tok);
								System.out.println("Privilege revoked successfully");
								System.out.println();
							}
							else
							{
								System.out.println("Authorization failure");
								System.out.println();
							}
						}
						break;
					case "INSERT":
						if(tok[1].equals("INTO"))
							insert(tok);
						else
							System.out.println("Insert improperly formatted. Usage: \"INSERT INTO\"");
						break;
					case "SELECT":
						if(tok[1].equals("*"))
							select(tok);
						else
							System.out.println("This program only supports \"SELECT *\"");
						System.out.println();
						break;
					case "EXIT":
						buf.close();
						input.close();
						fstream.close();
						statement.close();
						conn.close();
						return;
				}
				count++;
			}
			buf.close();
			input.close();
			fstream.close();
			statement.close();
			conn.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			System.out.println("Error: " + e.getMessage());
		} finally {
			try
			{
				if(statement != null)
					statement.close();
			} catch (SQLException se2) {}
			
			try
			{
				if(conn != null)
					conn.close();
			} catch (SQLException se) {
				se.printStackTrace();
			}
		}
	}

	public static List<String> parseCommand(final String attributes)
	{
		final List<String> values = new ArrayList<String>();
		final Matcher m = PARSEQUOTES.matcher(attributes);
		while(m.find())
			values.add(m.group(1));
		return values;
	}

	public static void login(String [] cmd)
	{
		try
		{
			statement = conn.createStatement();
			String query = "SELECT * FROM Users WHERE username = '" + cmd[1] + "' AND password = '" + cmd[2] + "'";
			ResultSet set = statement.executeQuery(query);

			boolean valid = false;
			while(set.next())
				valid = true;
			if(valid)
			{
				System.out.println("Login successful");
				currUser = cmd[1];
			}
			else
				System.out.println("Invalid login");
			set.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static int generateUser(String tableName)
	{
		int userid = 1;
		
		try
		{
			statement = conn.createStatement();
			String query = "SELECT * FROM " + tableName + " ORDER BY 1";
			ResultSet set = statement.executeQuery(query);

			boolean valid = false;
			while(set.next())
			{
				int id = set.getInt(1); //id is in the first column
				if(id == userid)
					userid++;
				valid = true;
			}

			if(!valid)
				System.out.printf("Table did not have data to perform dynamic generation of UID.\n");
			set.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
		return userid;
	}

	public static void createRole(String [] cmd)
	{
		int userid = -1;
		
		try
		{
			statement = conn.createStatement();
			userid = generateUser("roles");
			String query = "INSERT INTO Roles " + "VALUES (" + userid + ", '" + cmd[2] + "', '" + cmd[3] + "')";
			statement.executeUpdate(query);
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void createUser(String [] cmd)
	{
		int userid = -1;
		
		try
		{
			statement = conn.createStatement();
			userid = generateUser("users");
			String query = "INSERT INTO Users " + "VALUES (" + userid + ", '" + cmd[2] + "', '" + cmd[3] + "')";
			statement.executeUpdate(query);
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void assignRole(String [] cmd)
	{
		int roleid = -1;
		int userid = -1;
		
		try
		{
			statement = conn.createStatement();
			String query = "SELECT userid, username FROM Users WHERE username = '" + cmd[2] + "'";
			ResultSet set = statement.executeQuery(query);
			set.next();
			userid = set.getInt("userid");
			set.close();

			statement = conn.createStatement();
			query = "SELECT roleid, rolename FROM Roles WHERE rolename = '" + cmd[3] + "'";
			set = statement.executeQuery(query);
			set.next();
			roleid = set.getInt("roleid");

			statement = conn.createStatement();
			query = "INSERT INTO UsersRoles " + "VALUES (" + userid + ", " + roleid + ")";
			statement.executeUpdate(query);
			set.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void grantPrivilege(String [] cmd)
	{
		int roleid = -1;
		int privateid = -1;

		try
		{
			statement = conn.createStatement();
			String query = "SELECT privid, privname FROM Privileges WHERE privname = '" + cmd[2] + "'";
			ResultSet set = statement.executeQuery(query);
			set.next();
			privateid = set.getInt("privid");
			set.close();

			statement = conn.createStatement();
			query = "SELECT roleid, rolename FROM Roles WHERE rolename = '" + cmd[4] + "'";
			set = statement.executeQuery(query);
			set.next();
			roleid = set.getInt("roleid");

			statement = conn.createStatement();
			query = "INSERT INTO RolesPrivileges " + "VALUES (" + roleid + ", " + privateid + ", '" + cmd[6] + "')";
			statement.executeUpdate(query);
			set.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void revokePrivilege(String [] cmd)
	{
		int roleid = -1;
		int privateid = -1;

		try
		{
			statement = conn.createStatement();
			String query = "SELECT privid, privname FROM Privileges WHERE privname = '" + cmd[2] + "'";
			ResultSet set = statement.executeQuery(query);
			set.next();
			privateid = set.getInt("privid");
			set.close();

			statement = conn.createStatement();
			query = "SELECT roleid, rolename FROM Roles WHERE rolename = '" + cmd[4] + "'";
			set = statement.executeQuery(query);
			set.next();
			roleid = set.getInt("roleid");

			statement = conn.createStatement();
			query = "DELETE FROM RolesPrivileges WHERE roleid = " + roleid + " AND privateid = " + privateid + " AND tableName = '" + cmd[6] + "'";
			statement.executeUpdate(query);
			set.close();
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void insert(String [] cmd)
	{
		int roleid = -1;
		int privateid = -1;
		int userid = -1;

		try
		{
			statement = conn.createStatement();
			String query = "SELECT privid, privname FROM Privileges WHERE privname = 'INSERT'";
			ResultSet set = statement.executeQuery(query);
			if(set.next() == true)
				privateid = set.getInt("privid");
			set.close();
			if(privateid == -1)
			{
				System.out.println("Privilege with name 'INSERT' was not found.");
				return;
			}
			
			statement = conn.createStatement();
			query = "SELECT userid, username FROM Users WHERE username = '" + currUser + "'";
			set = statement.executeQuery(query);
			if(set.next())
				userid = set.getInt("userid");
			set.close();
			if(userid == -1)
			{
				System.out.println("Current user = " + currUser + "is not found in Users table.");
				return;
			}
			
			statement = conn.createStatement();
			query = "SELECT roleid, rolename FROM Roles WHERE rolename = '" + cmd[6] + "'";
			set = statement.executeQuery(query);
			if(set.next())
				roleid = set.getInt("roleid");
			set.close();
			if(roleid == -1)
			{
				System.out.println("roleid not found in Roles table for rolename = '" + cmd[6] + "'");
				return;
			}
			
			statement = conn.createStatement();
			String subquery = "(SELECT roleid, userid FROM UsersRoles WHERE userid = " + userid + " AND roleid = " + roleid + ") s";
			query = "SELECT s.roleid, role.privid, role.tablename FROM RolesPrivileges role RIGHT JOIN " + subquery + " ON s.roleid = role.roleid WHERE tableName = '" + cmd[2] + "' AND privid = " + privateid;
			
			boolean privilege = false;
			set = statement.executeQuery(query);
			while(set.next())
				privilege = true;
			set.close();

			if(privilege == true)
			{
				System.out.println("Row inserted successfully");
				System.out.println();
				List<String> attr = parseCommand(cmd[3]);
				
				String attr_str = "";
				for(int i = 0; i < attr.size(); i++)
					attr_str = attr_str + "'" + attr.get(i) + "',";
				attr_str = attr_str + "'" + roleid + "'";
				statement = conn.createStatement();
				query = "INSERT INTO " + cmd[2] + " VALUES (" + attr_str + ")";
				statement.executeUpdate(query);
			}
			else
			{
				System.out.println("Authorization failure");
				System.out.println();
			}
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void select(String [] cmd)
	{
		int userid = -1;
		int privateid = -1;
		List<Integer> roles = new ArrayList<Integer>();

		try
		{
			statement = conn.createStatement();
			String query = "SELECT privid, privname FROM Privileges WHERE privname = 'SELECT'";
			ResultSet set = statement.executeQuery(query);
			if(set.next())
				privateid = set.getInt("privid");
			set.close();
			if(privateid == -1)
			{
				System.out.println("Privilege with name 'INSERT' was not found.");
				return;
			}

			statement = conn.createStatement();
			query = "SELECT userid, username FROM Users WHERE username = '" + currUser + "'";
			set = statement.executeQuery(query);
			if(set.next())
				userid = set.getInt("userid");
			set.close();
			if(userid == -1)
			{
				System.out.println("Current user = " + currUser + " not found in Users table.");
				return;
			}

			statement = conn.createStatement();
			String subquery = "(SELECT roleid, userid FROM UsersRoles WHERE userid = " + userid + ") s";
			query = "SELECT s.roleid, role.privid, role.tablename FROM RolesPrivileges role RIGHT JOIN " + subquery + " ON s.roleid = role.roleid WHERE tableName = '" + cmd[3] + "' AND privid = " + privateid + " ORDER BY s.roleid";

			boolean privilege = false;
			set = statement.executeQuery(query);
			while(set.next())
			{
				privilege = true;
				roles.add(set.getInt("roleid"));
				String temp_tableName = set.getString("tablename");
				int temp_privateid = set.getInt("privid");
				
				if( !(temp_tableName.equals(cmd[3])) || (privateid != temp_privateid))
				{
					System.out.println("Table Name and/or Privilege ID does not match the given query");
					privilege = false;
				}
			}
			set.close();

			if(privilege == true)
			{
				String totalRoles = "";
				for(int i=0; i < roles.size(); i++)
				{
					if(i != roles.size() - 1)
						totalRoles = totalRoles + "roleid = " + roles.get(i) + " or ";
					else
						totalRoles = totalRoles + "roleid = " + roles.get(i);
				}

				statement = conn.createStatement();
				query = "SELECT * FROM " + cmd[3];
				set = statement.executeQuery(query);
				ResultSetMetaData md = set.getMetaData();
				int num_cols = md.getColumnCount() - 2;

				for(int i=1; i <= num_cols; i++)
				{
					String col_name = md.getColumnName(i);
					if(i == num_cols)
						System.out.print(col_name);
					else
						System.out.printf("%s, ", col_name);
				}
				System.out.println();
				
				while(set.next())
				{
					String row = "";
					for(int col=1; col <= num_cols; col++)
					{
						int ownerRole = set.getInt("OwnerRole");
						if(col != num_cols)
							row = row + set.getString(col) + ", ";
						else
							row = row + set.getString(col);
					}
					System.out.println(row);
				}
				set.close();
			}
			else
				System.out.println("Authorization failure");
		} catch(SQLException se) {
			se.printStackTrace();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
