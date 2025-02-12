'''
1. v 生成地圖
1.5. v 地圖轉換成row/col制
2. v 判斷地圖有沒有糖果消除
3. v 消除的是不是條紋糖果
4. v 計算分數
5. v 糖果移動 (至少一半要可以移動)
6. v 如果移動糖果跳回2, 沒移動跳到7
7. v 總分 
'''
import numpy as np
class candycrush:
    def __init__(self):
        self.CANDY_COLOR_TYPES = np.array([0,1,2,3,4,5]) # Red,Blue,Green, Yellow,Orange,Purple
        self.MATRIX_N = 6
        self.STRIPE_CANDY_N = 4
        self.EMPTY = 7
        
        # candy_matrix = np.random.choice(candy_color_types, 36, replace=True)
    
    def create_CC_array(self):
        self.candy_matrix = np.random.choice(self.CANDY_COLOR_TYPES, self.MATRIX_N**2, replace=True)
        self.candy_stripe_pos = np.random.choice(np.arange(0,self.MATRIX_N**2), self.STRIPE_CANDY_N, replace=False)
        self.candy_stripe_type = np.random.choice(np.arange(0,2), self.STRIPE_CANDY_N, replace=True)
        self.total_score = 0
        self.matrixing()
    
    def set_CC_array(self,_array,stripe_pos,stripe_type):
        self.candy_matrix = _array
        self.candy_stripe_pos = stripe_pos
        self.candy_stripe_type = stripe_type
        self.total_score = 0
        self.matrixing()
        
    def matrixing(self):
        self.candy_matrix = self.candy_matrix.reshape(self.MATRIX_N,self.MATRIX_N)
        self.candy_stripe_row = (self.candy_stripe_pos / 6).astype(int)
        self.candy_stripe_col = (self.candy_stripe_pos - 6*self.candy_stripe_row).astype(int)
    
    def update_matrix(self):
        clr_matrix = np.zeros(self.MATRIX_N**2).astype(int).reshape(self.MATRIX_N,self.MATRIX_N)
        dead_matrix = np.zeros(self.MATRIX_N**2).astype(int).reshape(self.MATRIX_N,self.MATRIX_N)
        row_score = 0
        # col_score = 0
        for section in range(2):
            if section==0:
                tmp_matrix = self.candy_matrix.copy()
            else:
                tmp_matrix = np.transpose(tmp_matrix)
                clr_matrix = np.transpose(clr_matrix)
            # print(tmp_matrix)
            for row in range(self.MATRIX_N):
                tmp_score = 0
                for i in range(4):
                    if tmp_matrix[row][0+i] == tmp_matrix[row][1+i] == tmp_matrix[row][2+i] != self.EMPTY:
                        # print('1',clr_matrix[row][0+i:2+i+1])
                        clr_matrix[row][0+i:2+i+1] = np.ones(3).astype(int)
                        tmp_score += 1
                row_score += tmp_score
        clr_matrix = np.transpose(clr_matrix)
        tmp_matrix = np.transpose(tmp_matrix)
        ##################################################################
        tmp_clr_matrix = clr_matrix.reshape(self.MATRIX_N**2).copy()
        # print('row_score:',row_score)
        c8=0
        for (i,stripe_idx) in enumerate(self.candy_stripe_pos):
            stripe_honrizontal = 0
            stripe_vertical = 1
            if tmp_clr_matrix[stripe_idx] and tmp_matrix.reshape(self.MATRIX_N**2)[stripe_idx] != self.EMPTY:
                # print('條紋炸彈',stripe_idx)
                if self.candy_stripe_type[i] == stripe_honrizontal: #
                    tmp_score = 0
                    match_flag = 0
                    for k in range(4):
                        if tmp_matrix[self.candy_stripe_row[i]][0+k] == tmp_matrix[self.candy_stripe_row[i]][1+k] == tmp_matrix[self.candy_stripe_row[i]][2+k] != self.EMPTY:
                            match_flag = 1
                    if match_flag:
                        for col in range(self.MATRIX_N):
                            if col==self.candy_stripe_col[i]:
                                clr_matrix[self.candy_stripe_row[i]][col] = 1
                                # print('HI---ssss-----------------')
                                continue
                            if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY and \
                                clr_matrix[self.candy_stripe_row[i]][col] != 1 and clr_matrix[self.candy_stripe_row[i]][col] != 2:
                            # if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY:
                                clr_matrix[self.candy_stripe_row[i]][col] = 2;
                                # tmp_matrix[self.candy_stripe_row[i]][col] = self.EMPTY
                                row_score += 1
                        pass
                    else:
                        for col in range(self.MATRIX_N):
                            if col==self.candy_stripe_col[i]:
                                clr_matrix[self.candy_stripe_row[i]][col] = 1
                                # print('HI---ssss-----------------')
                                continue
                            if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY and \
                                clr_matrix[self.candy_stripe_row[i]][col] != 2:
                            # if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY:
                                clr_matrix[self.candy_stripe_row[i]][col] = 2;
                                # tmp_matrix[self.candy_stripe_row[i]][col] = self.EMPTY
                                row_score += 1
                    '''
                    for k in range(4):
                        # print(tmp_matrix[self.candy_stripe_row[i]])
                        if tmp_matrix[self.candy_stripe_row[i]][0+k] == tmp_matrix[self.candy_stripe_row[i]][1+k] == tmp_matrix[self.candy_stripe_row[i]][2+k] != self.EMPTY:
                            tmp_score+=1
                            if tmp_score==1:
                                tmp_score+=1
                    o = np.count_nonzero(clr_matrix[self.candy_stripe_row[i]]);
                    if np.count_nonzero(clr_matrix[self.candy_stripe_row[i]]) == self.MATRIX_N and \
                        tmp_matrix[self.candy_stripe_row[i]].all()!=tmp_matrix[self.candy_stripe_row[i]][self.candy_stripe_col[i]].repeat(6).all():
                        row_score += 2
                    x=0
                    # print('clr_matrix=\n',clr_matrix)
                    for col in range(self.MATRIX_N):
                        if col==self.candy_stripe_col[i]:
                            clr_matrix[self.candy_stripe_row[i]][col] = 2
                            # print('HI---ssss-----------------')
                            continue
                        if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY and \
                            clr_matrix[self.candy_stripe_row[i]][col] != 2:
                        # if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY:
                            clr_matrix[self.candy_stripe_row[i]][col] = 2;
                            # tmp_matrix[self.candy_stripe_row[i]][col] = self.EMPTY
                            row_score += 1
                            x+=1
                    '''
                    # print('x:',x)
                    # print('tmp_score:',tmp_score)
                    
                    # if c8==0:
                    row_score -= tmp_score
                    #     c8=1
                    # row_score -= 1
                    # row_score += o-tmp_score
                    
                    # print('1')
                else: # stripe_vertical
                    # print("stripe_vertical")
                    clr_matrix = np.transpose(clr_matrix)
                    tmp_matrix = np.transpose(tmp_matrix)
                    tmp_score = 0
                    match_flag = 0
                    for k in range(4):
                        if tmp_matrix[self.candy_stripe_col[i]][0+k] == tmp_matrix[self.candy_stripe_col[i]][1+k] == tmp_matrix[self.candy_stripe_col[i]][2+k] != self.EMPTY:
                            match_flag = 1
                    if match_flag:
                        for col in range(self.MATRIX_N):
                            if col==self.candy_stripe_row[i]:
                                clr_matrix[self.candy_stripe_col[i]][col] = 1
                                # print('HI---ssss-----------------')
                                continue
                            if tmp_matrix[self.candy_stripe_col[i]][col] != self.EMPTY and \
                                clr_matrix[self.candy_stripe_col[i]][col] != 1 and clr_matrix[self.candy_stripe_col[i]][col] != 2:
                            # if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY:
                                clr_matrix[self.candy_stripe_col[i]][col] = 2;
                                # tmp_matrix[self.candy_stripe_row[i]][col] = self.EMPTY
                                row_score += 1
                        pass
                    else:
                        for col in range(self.MATRIX_N):
                            if col==self.candy_stripe_row[i]:
                                clr_matrix[self.candy_stripe_col[i]][col] = 1
                                # print('HI---ssss-----------------')
                                continue
                            if tmp_matrix[self.candy_stripe_col[i]][col] != self.EMPTY and \
                                clr_matrix[self.candy_stripe_col[i]][col] != 2:
                            # if tmp_matrix[self.candy_stripe_row[i]][col] != self.EMPTY:
                                clr_matrix[self.candy_stripe_col[i]][col] = 2;
                                # tmp_matrix[self.candy_stripe_row[i]][col] = self.EMPTY
                                row_score += 1
                    '''
                    for k in range(4):
                        # print(tmp_matrix[self.candy_stripe_col[i]])
                        if tmp_matrix[self.candy_stripe_col[i]][0+k] == tmp_matrix[self.candy_stripe_col[i]][1+k] == tmp_matrix[self.candy_stripe_col[i]][2+k] != self.EMPTY:
                            tmp_score+=1
                            if tmp_score==1:
                                tmp_score+=1
                    o = np.count_nonzero(clr_matrix[self.candy_stripe_col[i]]);
                    # print('o:',)
                    # print(np.count_nonzero(clr_matrix[self.candy_stripe_col[i]]))
                    # print(self.MATRIX_N)
                    # print(tmp_matrix[self.candy_stripe_col[i]])
                    # print(tmp_matrix[self.candy_stripe_col[i]][self.candy_stripe_row[i]].repeat(6))
                    if np.count_nonzero(clr_matrix[self.candy_stripe_col[i]]) == self.MATRIX_N and \
                        tmp_matrix[self.candy_stripe_col[i]].all()!=tmp_matrix[self.candy_stripe_col[i]][self.candy_stripe_row[i]].repeat(6).all():
                        row_score += 2
                    x = 0
                    # print('clr_matrix=\n',np.transpose(clr_matrix))
                    for col in range(self.MATRIX_N):
                        # print(col,self.candy_stripe_row[i],col)
                        if col==self.candy_stripe_row[i]:
                            clr_matrix[self.candy_stripe_col[i]][col] = 2;
                            # print('HI--------------------')
                            continue
                        if tmp_matrix[self.candy_stripe_col[i]][col] != self.EMPTY and \
                            clr_matrix[self.candy_stripe_col[i]][col] != 2:
                        # if tmp_matrix[self.candy_stripe_col[i]][col] != self.EMPTY:
                            clr_matrix[self.candy_stripe_col[i]][col] = 2;
                            # tmp_matrix[self.candy_stripe_col[i]][col] = self.EMPTY;
                            x+=1
                            row_score += 1
                    # print('x:',x)
                    
                        # print('tmp_score:',tmp_score)
                    # row_score += o-tmp_score
                    # if c8==0:
                    #     row_score -= tmp_score
                    #     c8=1
                    # row_score -= 1
                    # print('tmp_score:',tmp_score)
                    row_score -= tmp_score
                    '''     
                    clr_matrix = np.transpose(clr_matrix)
                    tmp_matrix = np.transpose(tmp_matrix)
                    # print('2')
                    
        self.candy_matrix = np.where(clr_matrix,self.EMPTY,tmp_matrix)
                    
        self.total_score += row_score
                    
                
        # print('clr_matrix\n',clr_matrix)

    def action(self,row,col,direction):
        up = 0
        down = 1
        left = 2
        right = 3
        if self.candy_matrix[row][col] != self.EMPTY:
            if direction == down:
                tmp_row = row+1
                if tmp_row < (self.MATRIX_N) and (self.candy_matrix[tmp_row][col]!=self.EMPTY):
                    self.swap(row,col,tmp_row,col)
            if direction == up:
                tmp_row = row-1
                if tmp_row >= 0 and (self.candy_matrix[tmp_row][col]!=self.EMPTY):
                    self.swap(row,col,tmp_row,col)
            if direction == left:
                tmp_col = col-1
                if tmp_col >= 0 and (self.candy_matrix[row][tmp_col]!=self.EMPTY):
                    self.swap(row,col,row,tmp_col)
            if direction == right:
                tmp_col = col+1
                if tmp_col < self.MATRIX_N and (self.candy_matrix[row][tmp_col]!=self.EMPTY):
                    self.swap(row,col,row,tmp_col)
            
    def swap(self,row,col,row2,col2):
        temp = self.candy_matrix[row][col]
        self.candy_matrix[row][col] = self.candy_matrix[row2][col2]
        self.candy_matrix[row2][col2] = temp
        for (i,_row) in enumerate(self.candy_stripe_row):
            _col = self.candy_stripe_col[i]
            if (_row==row) and (_col==col):
                self.candy_stripe_row[i] = row2
                self.candy_stripe_col[i] = col2
                self.candy_stripe_pos[i] = row2*self.MATRIX_N+col2
                continue
            if (_row==row2) and (_col==col2):
                self.candy_stripe_row[i] = row
                self.candy_stripe_col[i] = col
                self.candy_stripe_pos[i] = row*self.MATRIX_N+col
                continue # for read
    def get_score(self):
        return self.total_score    

    
def DectoBin(dec, fill_bits):
    DtoB_list = []
    for i in range(len(dec)):
        record_in_DtoB = dec[i]
        record_in = bin(record_in_DtoB)
        record_in_nonb = record_in.split('b')[1]
        record_in_save = record_in_nonb.zfill(fill_bits)
        DtoB_list.append(record_in_save)
    return DtoB_list

def comb_clear_bin(*input):
    _str = ''
    for i in range(len(input)):
        #str += '_'
        # str += str(input[i])
        _str += f'{input[i]}'
    clean_str = _str.replace('[', '')
    clean_str = clean_str.replace(']', '')
    clean_str = clean_str.replace(' ', '')
    clean_str = clean_str.replace(',', '')
    clean_str = clean_str.replace('\'', '')
    return clean_str
import json
def CC_main(num=0,max=0):
    print("----------------- CNADY CRUSH -----------------")
    a = candycrush();
    a.create_CC_array()
    # print(a.candy_matrix)
    if max>num:
        jsonFile = open('./spectial.json','r')
        spectial_case = json.load(jsonFile)
        spectial_case = spectial_case[f"{num}"]
        a.set_CC_array(np.array(spectial_case["in_colors"]).reshape(36),np.array(spectial_case["in_starting_pos"]),np.array(spectial_case["in_stripe"]))
    
    BIN_candy_matrix = DectoBin(a.candy_matrix.reshape(36),fill_bits=3)
    # BIN_stripe_pos = DectoBin(a.candy_stripe_pos,fill_bits=3)
    BIN_stripe_type = DectoBin(a.candy_stripe_type,fill_bits=1)
    BIN_stripe_row = DectoBin(a.candy_stripe_row,fill_bits=3)
    BIN_stripe_col = DectoBin(a.candy_stripe_col,fill_bits=3)
    print('matrix()\n',a.candy_matrix)
    a.update_matrix()
    tmp_score = a.get_score()
    maxtrix_row_col = np.array([0,1,2,3,4,5])
    actions = np.array([0,1,2,3])
    rnd_row = np.random.choice(maxtrix_row_col, 10, replace=True)
    rnd_col = np.random.choice(maxtrix_row_col, 10, replace=True)
    rnd_action = np.random.choice(actions, 10, replace=True)
    if max>num:
        rnd_row = (np.array(spectial_case["in_action_pos"]) / 6).astype(int)
        rnd_col = np.array(spectial_case["in_action_pos"]) - rnd_row*6
        rnd_action = np.array(spectial_case["in_action"])
    BIN_rnd_row = DectoBin(rnd_row,fill_bits=3)
    BIN_rnd_col = DectoBin(rnd_col,fill_bits=3)
    BIN_rnd_action = DectoBin(rnd_action,fill_bits=2)
    # print('rnd_action',rnd_action)
    for i in range(len(rnd_action)):
        print('action row/col',rnd_row[i],rnd_col[i], rnd_action[i])
        print('matrix\n',a.candy_matrix)
        a.action(rnd_row[i],rnd_col[i],rnd_action[i])
        a.update_matrix()
        print('matrix(update)\n',a.candy_matrix)
        print(a.get_score())
        # exit()
    BIN_score = DectoBin([a.get_score()],fill_bits=7)
    cod = comb_clear_bin(BIN_candy_matrix,BIN_stripe_row,BIN_stripe_col,BIN_stripe_type,
                         BIN_rnd_row,BIN_rnd_col,BIN_rnd_action,
                         BIN_score)
    
    # print(cod)
    # print(a.get_score())
    if (tmp_score == a.get_score() and tmp_score<10) or a.get_score()<5:
        no_action_map = 1
    else:
        no_action_map = 0
    return cod,no_action_map
    # print(a.candy_matrix)
    # a.matrixing()
    # a.update_matrix()
    
    
def SaveFile(pattern_all,_path='./'):

    GT_path = os.path.join(_path, "Pattern.dat")
    # 如果資料夾不存在，則建立
    if not os.path.exists(_path):
        os.makedirs(_path)
    # 寫入檔案
    with open(GT_path, "w") as file:
        file.write(pattern_all)
        
    print(f"資料已成功儲存至 {GT_path}")
if __name__ == '__main__':
    import os
    os.system('cls')
    print('run CC_Pattern.py')
    patterns = []
    jsonFile = open('./spectial.json','r')
    spectial_case = json.load(jsonFile)
    maxlen = len(spectial_case)-1
    sample_N = 100
    i=0
    while i<sample_N:
        bin_code, bad_map = CC_main(i,max=maxlen)
        if bad_map == 0:
            i += 1
            patterns.append(bin_code)
        # i=200
    # for i in range(sample_N*4):
    #     # print(i)
    #     bin_code, bad_map = CC_main(i)
    #     if bad_map == 1:
    #         i -= 1
    #     else:
    #         patterns.append(bin_code)
    # patterns = patterns[0:sample_N]

    pattern_str_all = '\n'.join(patterns)
    SaveFile(pattern_str_all)
    
    # print('-----------------------------------------------------\n') 
    # print('pattern:',patterns,'\npattern lens',len(patterns))
    # print('-----------------------------------------------------\n') 
    # print("----------------------------------------------------------\n\n")
    # print("cod=")
    cod  = f'in_color[2:0]*36          ({3*36} bits)+\n'
    cod += f'in_starting_pos[5:3]*4    ({3*4} bits)+\n'
    cod += f'in_starting_pos[2:0]*4    ({3*4} bits)+\n'
    cod += f'in_stripe*4               ({1*4} bits)+\n'
    cod += f'in_starting_pos[5:3]*10   ({3*10} bits)+\n'
    cod += f'in_starting_pos[2:0]*10   ({3*10} bits)+\n'
    cod += f'in_action[1:0]*10         ({2*10} bits)+\n'
    cod += f'out_score[6:0]            ({7*1} bits)+\n'

    with open("./Pattern_contrast.txt", "w") as file:
        file.write(cod)
    # print(" + +  +  +  + + ")
    # print("cod="3bits *36 + starting_pos[5:3]*4 + starting_pos[2:0]*4 + in_stripe*4")
    # print("\n\n----------------------------------------------------------")
 
