%{
/* need this for the call to atof() below */
#include <math.h>
#define MAXINSTRUCTIONS 500
#define MAXVARS 500
typedef enum { false=1, true } bool;
enum {ALLOC = 1, LOAD, LOADA, STORE, MOVE, ADD, SUB, MUL, DIV, MOD, CMP, B, BEQ, BLE, BLT, BGE, BGT, BNE, READ, WRITE, LABELD};
enum {REGISTER = 1, DIRECT, INDIRECT, IMMEDIATE}; 
typedef enum {NONE=1, LESSTHAN, GREATERTHAN, EQUAL} compare;
typedef enum {NOERROR, ERROR} error_code;
typedef struct {
	unsigned char op_code;
	unsigned char mode:5;
	unsigned char reg1_no:3;
	union {
		unsigned short location;
			 short immediate_const;
			 char reg2_no:3;
	} arg2;
} Instruction;
typedef struct {
	char	variable[50];
	bool	resolved;
	unsigned	short	location;
	struct	Symbols *next;
} Symbols;

Instruction instructions[MAXINSTRUCTIONS];
Symbols *symbolTable;
int registerValues[8];
//long int memory[65536];
long int memory[MAXINSTRUCTIONS];

long int countNewLines = 0;

//char *variables[MAXVARS];
compare cmpRes;
error_code isError = NOERROR;
int numErrors;
int freePointer = 0;
int curInstr = 1; //NOT Same as Program Counter (PC)-- Total instructions in the input file
int programCounter = 1;
char *varName;
int curArg = 0;
int curVars = 0;


void printUnresolvedVariablesAndLabels() {
//	printf("In resolving varibales");
	int pCount = 1;
	for (;pCount < curInstr; pCount++) {
		if(instructions[pCount].mode == DIRECT && instructions[pCount].arg2.location == 0) {
//			printf("\n $$$$$$$$$$$$$$$$Found ONE Backpatching$$$$$$$$$$$$$$$$$$$$$$$$$$$ \n"); 
		}
	}
}

void modifySymbolTableEntry(char *varName, int location, bool resolved) {
//	printf("ModifySymboltableEntry %s at %d", varName, location);
	Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
	temp1 = symbolTable->next;
	while(temp1 != NULL) {
		if(strcmp(temp1->variable,varName) == 0) {
			temp1->location = location;
			temp1->resolved = resolved;
		}
		temp1 = temp1->next;
	}
}

void fixLocations(int location, int instructionStart) {
//	printf("Fix locations for %d at %d", location, instructionStart);
	int nextLoc;
	nextLoc = instructions[instructionStart].arg2.location;
	while(nextLoc != 0) {
		instructions[instructionStart].arg2.location = location;
		instructionStart = nextLoc;
//		printf("Fix locations for %d at %d", location, instructionStart);
		nextLoc = instructions[instructionStart].arg2.location;
	}
	instructions[instructionStart].arg2.location = location;
}



void insertIntoSymbolTable(char *varName, int location, bool resolved) {
//		printf("InsertIntoSymboltable");		
//		perror("InsertIntoSymboltable");		
		bool matched = false;
		
		Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
		temp1 = symbolTable->next;
//		printf("%s is varName with resolved: %d \t", varName, resolved);
		while(temp1 != NULL) {
			if( strcmp(temp1->variable,varName) == 0 ) {
			//if( strcmp(token,varName) == 0 ) {
				matched = true;
				if (resolved == true && temp1->resolved == true ) {
//					printf("%s allocated multiple times",varName);
					
					printf("line %d: %s is not an unresolved label\n", countNewLines, varName);
					isError = ERROR;
					numErrors++;
				} else if(resolved == true && temp1->resolved == false) {
//					printf("Resolving an old label");
					temp1->resolved = true;
					if(temp1->location != 0) {
//						fixLocations(location, startInstruction);
						fixLocations(location, temp1->location);
					}  
					temp1->location = location;//DO SOMETHING MORE
					
				} /*else if (resolved == true && temp1->resolved == true ) {
					printf("%s allocated multiple times",varName);
					isError = ERROR;
				} else if (resolved == false && temp1->resolved == true){ //Uses getAddress

				} else if (resolved == false && temp1->resolved == false) { //Unresolved label used again
					printf("Add unresolved into linkedlist \n");//TODO
					//Classroom idea::
					temp1->location = location;	
				}*/
			}
//			else
//				printf("Doent match %s \t", temp1->variable);
			temp1 = temp1->next;
		}

		if( matched == false) {
			char *token;
			token = strtok(varName, ":");
//			printf("Inserting into Symbol table %s\n", token);
			Symbols *temp = (Symbols *) malloc(sizeof(Symbols));
			//strcpy(temp->variable, varName);
			strcpy(temp->variable, token);
			temp->location = location;
			temp->resolved = resolved;
			temp->next = symbolTable->next;
			symbolTable->next = temp;
		} 
}

/*void insertIntoSymbolTable(char *varName, int location, bool resolved) {
	printf("insertIntoSymbolTable(%s, %d, %d) \n", varName,location, resolved);

	if( resolved == true) {
		//Change in all pre-used labels 
		Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
		temp1 = symbolTable->next;
		while(temp1 != NULL) {
			if( strcmp(temp1->variable,varname) == 0 ) {
				if(temp1->resolved == false) {
					temp1->resolved = true;
					temp1->location = location;
				}
			}
		}
		
		Symbols *temp = (Symbols *) malloc(sizeof(Symbols));
		strcpy(temp->variable, varName);
		temp->location = location;
		temp->resolved = resolved;
		temp->next = symbolTable->next;
		symbolTable->next = temp;
	} else {
		Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
		temp1 = symbolTable->next;
		while(temp1 != NULL) {
			if( strcmp(temp1->variable,varname) == 0 ) {
				if(temp1->resolved == false) 
					temp1->location = 
			}
		}
		
		/*Symbols *temp = (Symbols *) malloc(sizeof(Symbols));
		strcpy(temp->variable, varName);
		temp->location = location;
		temp->resolved = resolved;
		temp->next = symbolTable->next;
		symbolTable->next = temp; 
	}

}*/

short getIfResolved(char* varName) {
//	printf("getAddress %s",varName);
	Symbols *temp;
	temp = symbolTable->next;
	while(temp != NULL) {
		/*char *token;
		token = strtok(temp->variable, ":");
		printf("~~~~%s~~~~~~~~%s",temp->variable, token);*/
		if (strcmp(varName,temp->variable) == 0)
		//if (strcmp(varName,token) == 0)
			return temp->resolved;
		temp = temp->next;
	}
	return 0;
}

short getAddress(char* varName) {
//	printf("getAddress %s",varName);
	Symbols *temp;
	temp = symbolTable->next;
	while(temp != NULL) {
		/*char *token;
		token = strtok(temp->variable, ":");
		printf("~~~~%s~~~~~~~~%s",temp->variable, token);*/
		if (strcmp(varName,temp->variable) == 0)
		//if (strcmp(varName,token) == 0)
			return temp->location;
		temp = temp->next;
	}
	return -1;
	//return 0;-- caused problem with first allocated variable
}

%}

digit           [0-9]
int             {digit}+
id              [A-Za-z_][A-Za-z0-9_]*
real            {int}"."{int}([eE][+-]?{int})?
labeld		[$][A-Za-z_][A-Za-z0-9_]*[:]
label		[$][A-Za-z_][A-Za-z0-9_]*
register	[r][0-7]
regAddress	[(]{register}[)]
regOffsetAdres	{digit}+{regAddress}

%%


.alloc		{ //printf( "Allocate keyword: %s\n", yytext );
			instructions[curInstr].op_code = ALLOC;	curArg = 0;
		}
load		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = LOAD;	curArg = 0;
		}
loada		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = LOADA;	curArg = 0;
		}
store 		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = STORE;	curArg = 0;
		}
move  		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = MOVE;	curArg = 0;
		}
mul   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = MUL;	curArg = 0;
		}
add   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = ADD;	curArg = 0;
		}
sub   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = SUB;	curArg = 0;
		}
div   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = DIV;	curArg = 0;
		}
mod   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = MOD;   curArg = 0;
		}
cmp   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = CMP;	curArg = 0;
		}
b     	 	{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = B;	curArg = 0;
		}
beq   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BEQ;	curArg = 0;
		}
ble   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BLE; 	curArg = 0;
		}
blt   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BLT;	curArg = 0;
		}
bge   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BGE;	curArg = 0;
		}
bgt    	 	{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BGT;	curArg = 0;
		}
bne   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = BNE;	curArg = 0;
		}
read   		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = READ;	curArg = 0; 
		}
write  		{// printf( "A keyword: %s\n", yytext );
			instructions[curInstr].op_code = WRITE;	curArg = 0;
		}

{label}		{// printf( "A Label: %s\n", yytext); 
			char *label = (char *) malloc (sizeof(yytext)+1);
			strcpy(label,yytext);
			bool ifResol = getIfResolved(label);
			if(ifResol == true) {
				instructions[curInstr].arg2.location = getAddress(label);	curArg = 0;		
		//		printf("Resolved %s to be at location %d", label, instructions[curInstr].arg2.location);
			} else if(ifResol == 0) {
		//		printf("Label doesnt exist before \n");
				insertIntoSymbolTable(label,curInstr,false);
			} else {
				Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
				temp1 = symbolTable->next;
				while (temp1 != NULL) {
					/*char *token;
					token = strtok(temp1->variable, ":");
					printf("~~~~%s~~~~~~~~%s \n",temp1->variable, token);
					if(strcmp(token,label) == 0) {*/
					if(strcmp(temp1->variable,label) == 0) {
		//				printf("Modifying Symbol table\n");
						instructions[curInstr].arg2.location = temp1->location;
						temp1->location = curInstr;
						break;
					}
					temp1 = temp1->next;
				}
			}
			/*if(instructions[curInstr].arg2.location == 0)
			//if(instructions[curInstr].arg2.location == 0  || instructions[instructions[curInstr].arg2.location].resolved == false)
			{
				printf("Label does not exist or not resolved before \n");
				char *label = (char *) malloc (sizeof(yytext)+1);
				strcpy(label,yytext);
				Symbols *temp1 = (Symbols *) malloc(sizeof(Symbols));
				temp1 = symbolTable->next;
				while (temp1 != NULL) {
					if(strcmp(temp1->variable,label) == 0) {
						printf("Modifying Symbol table\n");
						instructions[curInstr].arg2.location = temp1->location;
						temp1->location = curInstr;
						break;
					}
					temp1 = temp1->next;
				}
				//modifySymbolTable(label,curInstr,false);
			} */
		}

{labeld}	{// printf( "New Label Declared: %s with Address at %d\n", yytext, curInstr);  
			char *label = (char *) malloc (sizeof(yytext)+1);
			//strncpy(label, yytext, sizeof(yytext)+1);
			strcpy(label, yytext);
			char* token = strtok(label, ":");
		//	printf("label is :%s  and token is %s \n",label, token);
			//insertIntoSymbolTable(label, curInstr, true);
			insertIntoSymbolTable(token, curInstr, true);
			instructions[curInstr].op_code = LABELD;
		}

{int}		{ //printf( "An integer: %s (%d)\n", yytext, atoi( yytext ) );
			if( curArg == 1 && instructions[curInstr].op_code == ALLOC ) {
				//variables[curVars] = (char *) malloc(sizeof(varName));	
				//insertIntoSymbolTable(varName, variables[curVars], true, 1);
				//insertIntoSymbolTable(varName, variables[curVars], true);
				insertIntoSymbolTable(varName, freePointer , true);
				freePointer += atoi(yytext);
				free(varName);
				curArg = 0;
			} else {
				instructions[curInstr].mode = IMMEDIATE;
				instructions[curInstr].arg2.immediate_const = atoi(yytext);
			}			
		
		}

{register}	{ //printf( "A Register: %s\n", yytext);
			instructions[curInstr].mode = REGISTER;
			if(curArg == 0) {
				instructions[curInstr].reg1_no = abs(*(yytext+1)); 
		//		printf ("instructions[%d].reg1_no: %d \t  yytext: %s \n",curInstr,instructions[curInstr].reg1_no, yytext);
				curArg++;	
			} else if (curArg == 1) {
				instructions[curInstr].arg2.reg2_no = abs(*(yytext+1)); 
		//		printf ("instructions[%d].arg2.reg2_no: %d \t  yytext: %s \n",curInstr,instructions[curInstr].arg2.reg2_no, yytext);
				curArg++;	
			}
		}

{regAddress}	{ //printf( "A Register Address: %s\n", yytext);
			instructions[curInstr].mode = INDIRECT;
			if(curArg == 0) {
				instructions[curInstr].reg1_no = *(yytext+1); 
				//printf ("instructions[curInstr].reg1_no: %d \t  yytext: %s \n",instructions[curInstr].reg1_no, yytext);
				curArg++;	
			} else {
				instructions[curInstr].reg1_no = *(yytext+1); 
				//printf ("instructions[curInstr].arg2.reg2_no: %d \t  yytext: %s \n",instructions[curInstr].arg2.reg2_no, yytext);
				curArg++;	
			}
		}

{id}            { //printf( "An identifier: %s\n", yytext );
			if(curArg == 0) {
				if ( instructions[curInstr].op_code == ALLOC) {
					short loc = getAddress(yytext);
					/*if(loc != 0) {
						printf("%s declared multiple times",yytext);
						isError = ERROR;
						numErrors++;
					}*/
					varName = (char *) malloc ( sizeof(yytext)+1);
					strcpy(varName, yytext);				
					curArg++;
				}
			} else {
				instructions[curInstr].mode = DIRECT;
				//instructions[curInstr].arg2.location = atoi(yytext);
				// Modified Later 
				//instructions[curInstr].arg2.location = getAddress(yytext);
				short loc = getAddress(yytext);
				if(loc == -1) {
					printf("line %d: variable %s not allocated\n", curInstr, yytext);
					isError = ERROR;
					numErrors++;
				}
				instructions[curInstr].arg2.location = memory[loc];
			}
		}


{regOffsetAdres} {// printf( "A Register Offset Address: %s NOT USED HERE\n", yytext);	
		}

[\n]+		{ //printf ("Ready for new instruction "); 
			countNewLines++;
			if(instructions[curInstr].op_code != ALLOC && instructions[curInstr].op_code != LABELD) {
				curInstr++;  
			}
			else if( curArg == 1 && instructions[curInstr].op_code == ALLOC ) {
				insertIntoSymbolTable(varName, freePointer , true);
				freePointer += 1;//Assuming this to be '2' for now.
				//free(varName);
			}
			curArg = 0;
		} 

{real}          {// printf( "A real: %s (%g)\n", yytext, atof( yytext ) );
		}

"+"|"-"|"*"|"/"  {//printf( "An operator: %s\n", yytext );
		}

"{"[^}\n]*"}"    /* eat up one-line comments */

[ \t,]+         /* eat up whitespace */

.                {//printf( "Unrecognized character: %s\n", yytext );
		}

%%



void printCode(int code) {
	switch(code) {
		case ALLOC:	printf("ALLOC");	break;
		case LOAD:	printf("LOAD");		break;
		case LOADA:	printf("LOADA");	break;
		case STORE: 	printf("STORE");	break;
		case MOVE:	printf("MOVE");		break;
		case ADD:	printf("ADD");		break;
		case SUB:	printf("SUB");		break;
		case MUL:	printf("MUL");		break;
		case DIV: 	printf("DIV");		break;
		case MOD:	printf("MOD");		break;
		case CMP:	printf("CMP");		break;
		case B:		printf("B");		break;
		case BEQ:	printf("BEQ");		break;
		case BLE:	printf("BLE");		break;
		case BLT:	printf("BLT");		break;
		case BGE:	printf("BGE");		break;
		case BGT:	printf("BGT");		break;
		case BNE:	printf("BNE");		break;
		case READ:	printf("READ");		break;
		case WRITE: 	printf("WRITE");	break;
		default:	printf("~~%d~~", code);	
	}
}

void printMode(int mode) {
	printf("\t");
	switch(mode) {
		case REGISTER:	printf("REGISTER");	break;
		case DIRECT:	printf("DIRECT  ");	break;
		case INDIRECT:	printf("INDIRECT");	break;
		case IMMEDIATE:	printf("IMMEDIATE");	break;
		default:	printf("~~~~~~%d~~", mode);
	}
}

void printArg2(int iNum) {
	printf("\t");
	if (instructions[iNum].mode ==  REGISTER)
		printf("Arg2: r%d \n", instructions[iNum].arg2.reg2_no); 
	else if (instructions[iNum].mode == INDIRECT)
		printf("Arg2: (r%d) \n", instructions[iNum].arg2.reg2_no); 
	else if (instructions[iNum].mode == DIRECT)
		printf("Arg2: %d \n", instructions[iNum].arg2.immediate_const); 
	else
		printf("Arg2: %d \n",instructions[iNum].arg2.location);
}

void print_instructions() {
	int	i = 1;
	for (; i<curInstr; i++) {
		printCode(instructions[i].op_code);
		printMode(instructions[i].mode);
		if(instructions[i].op_code == B || instructions[i].op_code == BLE || instructions[i].op_code == BLT || instructions[i].op_code == BGE || instructions[i].op_code == BGT || instructions[i].op_code == BEQ || instructions[i].op_code == BNE) {
		}
		else
			printf("\t Arg1: r%d",instructions[i].reg1_no);
		printArg2(i);
		/*if (instructions[i].mode ==  REGISTER || instructions[i].mode == INDIRECT)
			printf("OP_CODE:%d \t mode: %d \t Arg1: %d \t Arg2: r%d \n", instructions[i].op_code,instructions[i].mode,instructions[i].reg1_no,instructions[i].arg2.reg2_no); 
		else if (instructions[i].mode == DIRECT)
			printf("OP_CODE:%d \t mode: %d \t Arg1: %d \t Arg2: %d \n", instructions[i].op_code,instructions[i].mode,instructions[i].reg1_no,instructions[i].arg2.immediate_const); 
		else
			printf("OP_CODE:%d \t mode: %d \t Arg1: %d \t Arg2: %d \n", instructions[i].op_code,instructions[i].mode,instructions[i].reg1_no,instructions[i].arg2.location); */
	}
}


void performOperation(int instructionNum) {
	switch( instructions[instructionNum].op_code) {
/*		case ALLOC:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] += instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] += instructions[instructionNum].arg2.reg2_no;		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.reg2_no];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.location];	break;
				}
				break; // Dont have to handle this: as Alloc is handled when an integer is observed */
		case LOAD:
//				printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] = memory[instructions[instructionNum].arg2.location];	break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] = memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					//case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] += instructions[instructionNum].arg2.reg2_no;		break;
					//case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.location];	break;
				}
//				printf("LOAD: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case LOADA: 	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:
//				printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				registerValues[instructions[instructionNum].reg1_no] = instructions[instructionNum].arg2.immediate_const;	break;	
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] = registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] = memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] = instructions[instructionNum].arg2.location;	break;
				}
//				printf("LOADA: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case STORE:	
//				printf("STORE Values:::: %d\t %d \t %d\t",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	memory[instructions[instructionNum].arg2.immediate_const] = registerValues[instructions[instructionNum].reg1_no];	break;
					case	INDIRECT:	memory[registerValues[instructions[instructionNum].arg2.reg2_no]] = registerValues[instructions[instructionNum].reg1_no];	
								//printf("\t %d \t %d \t %d \t ",instructions[instructionNum].arg2.reg2_no , registerValues[instructions[instructionNum].arg2.reg2_no], memory[registerValues[instructions[instructionNum].arg2.reg2_no]]);	
								break;
					case	REGISTER:	//printf("Reached \n");	
				memory[instructions[instructionNum].arg2.reg2_no] = registerValues[instructions[instructionNum].reg1_no];	break;
					case	DIRECT:		memory[instructions[instructionNum].arg2.location] = registerValues[instructions[instructionNum].reg1_no];	break;
				}
				//printf("STORE: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;

				break;
		case MOVE:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	//printf("%d \t",instructions[instructionNum].arg2.immediate_const);
								registerValues[instructions[instructionNum].reg1_no] = instructions[instructionNum].arg2.immediate_const;		break;
					case	REGISTER:	//printf("%d \t",instructions[instructionNum].arg2.reg2_no);
								//printf("%d and %d \n",registerValues[instructions[instructionNum].reg1_no] , registerValues[instructions[instructionNum].arg2.reg2_no]);	
								registerValues[instructions[instructionNum].reg1_no] = registerValues[instructions[instructionNum].arg2.reg2_no];	break;
				//	case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.reg2_no];	break;
				//	case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.location];	break;
				}
				//printf("MOVE: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case ADD:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] += instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] += registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] += memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] += memory[instructions[instructionNum].arg2.location];	break;
				}
				//printf("ADD: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case SUB:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] -= instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] -= registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] -= memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] -= memory[instructions[instructionNum].arg2.location];	break;
				}
				//printf("SUB: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case MUL:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] *= instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] *= registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] *= memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] *= memory[instructions[instructionNum].arg2.location];	break;
				}
				//printf("MUL: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case DIV:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] /= instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] /= registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] /= memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] /= memory[instructions[instructionNum].arg2.location];	break;
				}
				//printf("DIV: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;
				break;
		case MOD:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[instructions[instructionNum].reg1_no] %= instructions[instructionNum].arg2.immediate_const;	break;
					case	REGISTER:	registerValues[instructions[instructionNum].reg1_no] %= registerValues[instructions[instructionNum].arg2.reg2_no];		break;
					case	INDIRECT:	registerValues[instructions[instructionNum].reg1_no] %= memory[registerValues[instructions[instructionNum].arg2.reg2_no]];	break;
					case	DIRECT:		registerValues[instructions[instructionNum].reg1_no] %= memory[instructions[instructionNum].arg2.location];	break;
				}
				programCounter++;	//printf("MOD: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
/*		case BEQ:	
		case B:		switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] == instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] == instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] == memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] == memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("B: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
		case BNE:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] != instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] != instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] != memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] != memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("BNE: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
		case BLE:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] <= instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] <= instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] <= memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] <= memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("BLE: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
		case BLT:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] < instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] < instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] < memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] < memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("BLT: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
		case BGE:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] >= instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] >= instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] >= memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] >= memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("BGE: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break;
		case BGT:	switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] > instructions[instructionNum].arg2.immediate_const)? 1: 0;	break;
					case	REGISTER:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] > instructions[instructionNum].arg2.reg2_no)? 1: 0;		break;
					case	INDIRECT:	registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] > memory[instructions[instructionNum].arg2.reg2_no])? 1: 0;	break;
					case	DIRECT:		registerValues[0] = (registerValues[instructions[instructionNum].reg1_no] > memory[instructions[instructionNum].arg2.location])? 1: 0;	break;
				}
				printf("BGT: %d\n",registerValues[instructions[instructionNum].reg1_no] );
				break; */
		case B:		
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				//cmpRes = NONE;
				programCounter = instructions[instructionNum].arg2.location;
				break;
		case BEQ:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				if(cmpRes == EQUAL)
					programCounter = instructions[instructionNum].arg2.location;
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		case BLE:
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				if(cmpRes == EQUAL || cmpRes == LESSTHAN)
					programCounter = instructions[instructionNum].arg2.location;
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		case BLT:
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				if(cmpRes == LESSTHAN)
					programCounter = instructions[instructionNum].arg2.location;
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		case BGE:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				//printf("IN BGE: cmpRes is %d\n", cmpRes);
				if(cmpRes == EQUAL || cmpRes == GREATERTHAN) {
					programCounter = instructions[instructionNum].arg2.location;
				//	printf("programCounter is %d",programCounter);
				}
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		case BGT:
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				if(cmpRes == EQUAL)
					programCounter = instructions[instructionNum].arg2.location;
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		case BNE: 
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				if(cmpRes == LESSTHAN || cmpRes == GREATERTHAN)
					programCounter = instructions[instructionNum].arg2.location;
				else
					programCounter++;
				//cmpRes = NONE;
				break;
		
		case CMP:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				switch(instructions[instructionNum].mode) {
					case	IMMEDIATE:	cmpRes = (registerValues[instructions[instructionNum].reg1_no] > instructions[instructionNum].arg2.immediate_const)? GREATERTHAN : (registerValues[instructions[instructionNum].reg1_no] < instructions[instructionNum].arg2.immediate_const)? LESSTHAN : EQUAL;	break;
					case	REGISTER:	//printf("\t%d\t%d\t%d\t",instructions[instructionNum].arg2.reg2_no,registerValues[instructions[instructionNum].arg2.reg2_no], registerValues[instructions[instructionNum].reg1_no]);
								cmpRes = (registerValues[abs(instructions[instructionNum].reg1_no)] > registerValues[abs(instructions[instructionNum].arg2.reg2_no)] )? 
	GREATERTHAN : (registerValues[abs(instructions[instructionNum].reg1_no)] < registerValues[abs(instructions[instructionNum].arg2.reg2_no)])? LESSTHAN : EQUAL ;		break;
					case	INDIRECT:	cmpRes = (registerValues[instructions[instructionNum].reg1_no] > memory[registerValues[abs(instructions[instructionNum].arg2.reg2_no)]])? GREATERTHAN : (registerValues[abs(instructions[instructionNum].reg1_no)] < memory[registerValues[abs(instructions[instructionNum].arg2.reg2_no)]])? LESSTHAN : EQUAL;	break;
					case	DIRECT:		cmpRes = (registerValues[instructions[instructionNum].reg1_no] > memory[instructions[instructionNum].arg2.location])? GREATERTHAN : (registerValues[instructions[instructionNum].reg1_no] < memory[instructions[instructionNum].arg2.location])? LESSTHAN : EQUAL;	break;
				} 
				programCounter++;
				//printf("CMP: %d\n", cmpRes );
				break;
		case READ:	
				//printf("%d\t %d \t %d",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				//printf("Reas integer\n");
				scanf("%d", &registerValues[instructions[instructionNum].reg1_no]); 
				//printf("Read value as: %d\n",registerValues[instructions[instructionNum].reg1_no] );	
				programCounter++;	break;
		case WRITE:	
				//printf("%d\t %d \t %d \t",instructions[instructionNum].op_code,instructions[instructionNum].mode,instructions[instructionNum].reg1_no);
				//printf("WRITE:: %d\n", registerValues[instructions[instructionNum].reg1_no]);	
				printf("%d\n", registerValues[instructions[instructionNum].reg1_no]);	
				programCounter++;	break;
		default: 	break; //printf("Value: %d\n", instructions[instructionNum].op_code);//	programCounter++;
	}
}

void performOperations() {
	//printf("Performing operations \n");
	while(programCounter < curInstr) {
		if(instructions[programCounter].op_code != 0)
			performOperation(programCounter);
		else
			programCounter++;
	//	printf("Performing operation %d \n",programCounter);
		//printCode(instructions[programCounter].op_code);
	}

}

void print_symbolTable() {
 //   printf("Symbol table \n");
    Symbols* temp = (Symbols *) malloc (sizeof(Symbols));
    temp = symbolTable->next;
    while(temp != NULL) {
//	printf("%s \t %d\t %d \n", temp->variable, temp->location, temp->resolved);
	temp = temp->next;
    }
}

void check_symbolTable() {
 //   printf("Symbol table \n");
    Symbols* temp = (Symbols *) malloc (sizeof(Symbols));
    temp = symbolTable->next;
    while(temp != NULL) {
	if(temp->resolved == false) {
		printf("Unresolved labels: \n %s\n",temp->variable);
		isError = ERROR;
		numErrors++;
	}
	//printf("%s \t %d\t %d \n", temp->variable, temp->location, temp->resolved);
	temp = temp->next;
    }
}

main( int argc, char **argv )
{
    symbolTable = (Symbols *) malloc (sizeof(Symbols));
    strcpy(symbolTable->variable, "") ;
    symbolTable->resolved = true;
    symbolTable->location = -1;
    symbolTable->next = NULL;

    ++argv, --argc;     /* skip over program name */
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;

    yylex();

   // printf("\n#########################################################\n");
   // print_instructions();
   // print_symbolTable();
    check_symbolTable();

   // printf("curinstr :::: %d\n", curInstr);    
    if (isError == NOERROR) {
//	printUnresolvedVariablesAndLabels();
	performOperations();
    }
    else
 	printf("%d ERROR(s) Detected --- Quitting\n",numErrors);
}
