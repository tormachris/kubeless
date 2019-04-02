package kubeless

import "fmt"

func main() {
	//Defining 2D matrices
	m1 := [3][3]int{
		[3]int{1, 1, 1},
		[3]int{1, 1, 1},
		[3]int{1, 1, 1},
	}
	m2 := [3][3]int{
		[3]int{1, 1, 1},
		[3]int{1, 1, 1},
		[3]int{1, 1, 1},
	}

	//Declaring a matrix variable for holding the multiplication results
	var m3 [3][3]int

	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			m3[i][j] = 0
			for k := 0; k < 3; k++ {
				m3[i][j] = m3[i][j] + (m1[i][k] * m2[k][j])
			}
		}
	}

	twoDimensionalMatrices := [3][3][3]int{m1, m2, m3}

	matrixNames := []string{"MATRIX1", "MATRIX2", "MATRIX3 = MATRIX1*MATRIX2"}
	for index, m := range twoDimensionalMatrices {
		fmt.Println(matrixNames[index],":")
		showMatrixElements(m)
		fmt.Println()
	}
}

//A function that displays matix elements
func showMatrixElements(m [3][3]int) {
	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			fmt.Printf("%d\t", m[i][j])
		}
		fmt.Println()
	}
}

/*

MATRIX1 1 :
1	1	1
1	1	1
1	1	1

MATRIX2 2 :
1	1	1
1	1	1
1	1	1

MATRIX3 = MATRIX1*MATRIX2 3 :
3	3	3
3	3	3
3	3	3

*/
