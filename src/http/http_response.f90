module http_response
    use, intrinsic :: iso_fortran_env, only: int64
    use http_header, only : header_type
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), allocatable :: url, content, method, err_msg
        integer :: status_code = 0
        integer(kind=int64) :: content_length = 0
        logical :: ok = .true.
        type(header_type), allocatable :: header(:)
    contains
        procedure :: append_header
        procedure :: header_value
    end type response_type

contains
    subroutine append_header(this, key, value)
        class(response_type), intent(inout) :: this
        character(*), intent(in) :: key, value
        type(header_type), allocatable :: temp(:)
        integer :: n
    
        if (allocated(this%header)) then
            n = size(this%header)
            allocate(temp(n+1))
            temp(1:n) = this%header
            temp(n+1) = header_type(key, value)
            call move_alloc(temp, this%header)
        else
            allocate(this%header(1))
            this%header(1) = header_type(key, value)
        end if
    
    end subroutine append_header

    ! The header_value function takes a key string as input and returns the corresponding 
    ! value as a string from a response_type object's header array, which contains key-value 
    ! pairs representing HTTP headers. If the key is not found, the function returns an empty
    !  string. If there are duplicates of the key in the header array, the function returns 
    ! the value associated with the first occurrence of the key.
    pure function header_value(this, key) result(val)
        class(response_type), intent(in) :: this
        character(*), intent(in) :: key
        character(:), allocatable :: val
        type(string_type) :: string_to_match
        integer :: i
        
        string_to_match = to_lower(string_type(key))
        
        do i=1, size(this%header)
            if(to_lower(string_type(this%header(i)%key)) == string_to_match) then
                val = this%header(i)%value
                return
            end if
        end do
    end function header_value
end module http_response
